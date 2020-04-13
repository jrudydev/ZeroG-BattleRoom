//
//  GameScene.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/27/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import SpriteKit
import GameKit
import GameplayKit
import Combine


extension Notification.Name {
  static let restartGame = Notification.Name("restartGame")
}


class GameScene: SKScene {
  
  var entityManager: EntityManager!
  var graphs = [String : GKGraph]()
  
  lazy var gameState: GKStateMachine = GKStateMachine(states: [
    WaitingForTap(scene: self),
    Playing(scene: self),
    GameOver(scene: self)])
  
  private var lastUpdateTime : TimeInterval = 0

  var borderBody: SKPhysicsBody!
  
  var numberOfTouches = 0
  var cam: SKCameraNode?
  var gameMessage: SKLabelNode?
  
//  var gameEnded: (() -> Void)?
//  var gameOver: (() -> Void)?
  
  var multiplayerNetworking: MultiplayerNetworking! {
    didSet {
      MultiplayerNetworkingSnapshot.shared.publisher
        .sink { elements in
          self.multiplayerNetworking.sendSnapshot(elements)
        }
        .store(in: &subscriptions)
      MultiplayerNetworkingSnapshot.shared.scene = self
    }
  }
  
  var isPlayer1: Bool {
    return self.entityManager.currentPlayerIndex == 0
  }
  
  var gameWon: Bool = false {
    didSet {
      self.gameState.enter(GameOver.self)
    }
  }
  
  private var subscriptions = Set<AnyCancellable>()
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    borderBody.friction = 0
    self.borderBody = borderBody
    
    self.entityManager = EntityManager(scene: self)
    
    let _ = SoundManager.shared
    self.setupGameMessage()
    
    self.gameState.enter(WaitingForTap.self)
  }
  
  override func update(_ currentTime: TimeInterval) {
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }
    let deltaTime = currentTime - self.lastUpdateTime
    self.entityManager.update(deltaTime)
    
    self.lastUpdateTime = currentTime
    self.gameState.update(deltaTime: currentTime)

    if self.isPlayer1 && self.isGameWon() {
      self.gameWon = true
    }
  }
}

extension GameScene {
  private func setupGameMessage() {
    self.gameMessage = self.childNode(withName: "//gameMessage") as? SKLabelNode
    if let gameMessage = self.gameMessage {
      gameMessage.name = AppConstants.ComponentNames.gameMessageName
      gameMessage.alpha = 0.0
//      gameMessage.run(SKAction.fadeIn(withDuration: 2.0))
    }
  }
}

extension GameScene: MultiplayerNetworkingProtocol {
  func matchEnded() {
    self.gameState.enter(GameOver.self)
    GameKitHelper.shared.match?.disconnect()
    GameKitHelper.shared.match = nil
  }
  
  func setPlayerAliases(playerAliases: [String]) {
    for (idx, alias) in playerAliases.enumerated() {
      let entity = self.entityManager.playerEntites[idx]
      if let aliasComponent = entity.component(ofType: AliasComponent.self) {
        aliasComponent.node.text = "\(alias) (0/\(resourcesNeededToWin))"
      }
    }
  }
  
  func movePlayerAt(index: Int, position: CGPoint, direction: CGVector) {
    if let player = self.entityManager.playerEntites[index] as? General,
      let playerComponent = player.component(ofType: SpriteComponent.self) {
      
      playerComponent.node.position = position
      player.impulse(vector: direction)
    }
  }
  
  func impactPlayer(player: GKPlayer) {
    let heroEntity = self.entityManager.playerEntites.first(where: { entity -> Bool in
      return entity == player
    })
    
    if let hero = heroEntity as? General {
      hero.impacted()
    }
  }
  
  func syncResources(resources: MultiplayerNetworking.SnapshotElementGroup) {
    for x in self.entityManager.resourcesEntities.count..<resources.count {
      self.entityManager.spawnResource(position: resources[x].position,
                                       vector: resources[x].vector)
    }
  }
  
  func syncPlayerAt(index: Int, position: CGPoint, vector: CGVector) {
    if let player = self.entityManager.playerEntites[index] as? General,
      let spriteComponent = player.component(ofType: SpriteComponent.self),
      let physicsComponent = player.component(ofType: PhysicsComponent.self) {
      
      spriteComponent.node.position = position
      physicsComponent.physicsBody.velocity = vector
    }
  }
  
  func moveResourceAt(index: Int, position: CGPoint, vector: CGVector) {
    if let package = self.entityManager.resourcesEntities[index] as? Package,
      let spriteComponent = package.component(ofType: SpriteComponent.self),
      let physicsComponent = package.component(ofType: PhysicsComponent.self) {
      
      spriteComponent.node.position = position
      physicsComponent.physicsBody.velocity = vector
    }
  }
  
  func syncResourceAt(index: Int, position: CGPoint, vector: CGVector) {
    if let package = self.entityManager.resourcesEntities[index] as? Package,
      let shapeComponent = package.component(ofType: ShapeComponent.self),
      let physicsComponent = package.component(ofType: PhysicsComponent.self) {
      
      shapeComponent.node.position = position
      physicsComponent.physicsBody.velocity = vector
    }
  }
  
  func grabResourceAt(index: Int, playerIndex: Int, player: GKPlayer) {
    guard let senderEntity = self.entityManager.playerEntites.first(where: { entity -> Bool in
      return entity == player
    }) else { return }
    
    let playerEntity = self.entityManager.playerEntites[playerIndex]
    
    guard let sendersHandsComponent = playerEntity.component(ofType: HandsComponent.self),
      let resource = self.entityManager.resourcesEntities[index] as? Package,
      let resourceShapeComponent = resource.component(ofType: ShapeComponent.self),
      !sendersHandsComponent.isHolding(shapeComponent: resourceShapeComponent) else { return }

    // Check if sender was the host
    if senderEntity === self.entityManager.playerEntites[0] {
      
      // Check if there are any other players holding the resource
      for player in self.entityManager.playerEntites {
        guard player !== playerEntity else { continue }
        guard let handsComponent = player.component(ofType: HandsComponent.self) else { continue }
        
        if handsComponent.isHolding(shapeComponent: resourceShapeComponent) {
          handsComponent.release(resource: resource)
          break
        }
      }
    
      sendersHandsComponent.grab(resource: resource)
    } else {
      
      // Check if there are any other players holding the resource
      for player in self.entityManager.playerEntites {
        guard player !== playerEntity else { continue }
        guard let handsComponent = player.component(ofType: HandsComponent.self) else { continue }
        
        if handsComponent.isHolding(shapeComponent: resourceShapeComponent) {
          // If so cancel and send correction back to client
          sendersHandsComponent.release(resource: resource)
          handsComponent.grab(resource: resource)
          
          self.multiplayerNetworking.sendAssignResource(index: index, playerIndex: playerIndex)
          
          return
        }
      }
    
      sendersHandsComponent.grab(resource: resource)
    }
  }
  
  func assignResourceAt(index: Int, playerIndex: Int) {
    guard let hero = self.entityManager.hero as? General,
      let heroHandscomponent = hero.component(ofType: HandsComponent.self),
      let player = self.entityManager.playerEntites[playerIndex] as? General,
      let playerHandsComponent = player.component(ofType: HandsComponent.self),
      let package = self.entityManager.resourcesEntities[index] as? Package else { return }
    
    heroHandscomponent.release(resource: package)
    playerHandsComponent.grab(resource: package)
  }
  
  func gameOver(player1Won: Bool) {
    self.gameWon = !player1Won
  }
  
  func setCurrentPlayerAt(index: Int) {
    self.entityManager.currentPlayerIndex = index
    self.gameState.enter(Playing.self)
    
    MultiplayerNetworkingSnapshot.shared.isSendingSnapshots = true
  }
}

extension GameScene {
  func isGameWon() -> Bool {
    guard self.entityManager.playerEntites.count > 0 else { return false }
        
    if let hero = self.entityManager.hero as? General,
      let teamComponent = hero.component(ofType: TeamComponent.self),
      let winningTeam = self.entityManager.winningTeam {
      
      var localDidWin = false
      switch winningTeam {
      case .team1:
        localDidWin = teamComponent.team == .team1
      case .team2:
        localDidWin = teamComponent.team == .team2
      }
      print(localDidWin ? "Won" : "Lost")
      self.multiplayerNetworking.sendGameEnd(player1Won: localDidWin)
      
      return true
    }
    
    return false 
  }
}
