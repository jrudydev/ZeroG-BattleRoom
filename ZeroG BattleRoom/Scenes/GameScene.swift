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
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  lazy var gameState: GKStateMachine = GKStateMachine(states: [
    WaitingForTap(scene: self),
    Playing(scene: self),
    GameOver(scene: self)])
  
  private var lastUpdateTime : TimeInterval = 0
  
  private(set) var viewModel: GameSceneViewModel!
  
  var cam: SKCameraNode?
  var gameMessage: SKLabelNode?
  
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
  
  private var gameWon: Bool = false {
    didSet {
      if let label = self.gameMessage {
        label.text = "\(self.gameWon ? "You Won" : "You Lost")"
        label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
      }
      
      self.gameState.enter(GameOver.self)
//      let gameOver = self.childNode(withName: "Something") as! SKSpriteNode
//      let textureName = self.gameWon ? "You Won" : "Game Over"
//      let texture = SKTexture(imageNamed: textureName)
//      let actionSequence = SKAction.sequence([
//        SKAction.setTexture(texture),
//        SKAction.scale(to: 1.0, duration: 0.25)])
//      
//      gameOver.run(actionSequence)
    }
  }
  
  private var subscriptions = Set<AnyCancellable>()
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    self.viewModel = GameSceneViewModel(frame: self.frame)
    
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

    for entity in self.entities {
      entity.update(deltaTime: deltaTime)
    }
    
    self.entityManager.update(deltaTime)
    
    self.lastUpdateTime = currentTime
    
    self.gameState.update(deltaTime: currentTime)
    
    if self.isGameWon() {
      self.gameWon = true
    }
  }
}

extension GameScene {
  func spawnResourceNode(position: CGPoint) {
    
    
//    if let resourceNode = self.viewModel.resourceNode?.copy() as! SKShapeNode? {
//      resourceNode.position = position
//      resourceNode.strokeColor = SKColor.green
//
//      self.addChild(resourceNode)
//      resourceNode.randomeImpulse()
//    }
  }
  
  func getWallSegment(number: Int,
                      orientation: GameSceneViewModel.WallOrientation = .horizontal) -> [Wall] {
    return self.viewModel.getWallSegment(number: number, orientation: orientation)
  }
}

extension GameScene {
  private func setupGameMessage() {
    self.gameMessage = self.childNode(withName: "//gameMessage") as? SKLabelNode
    if let gameMessage = self.gameMessage {
      gameMessage.name = AppConstants.ComponentNames.gameMessageName
      gameMessage.alpha = 0.0
      gameMessage.run(SKAction.fadeIn(withDuration: 2.0))
    }
  }
}

extension GameScene: MultiplayerNetworkingProtocol {
  func setPlayerAliases(playerAliases: [String]) {
    for (idx, alias) in playerAliases.enumerated() {
      let entity = self.entityManager.playerEntites[idx]
      if let aliasComponent = entity.component(ofType: AliasComponent.self) {
        aliasComponent.node.text = alias
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
//    let player = self.viewModel.players[index]
//    player.position = position
//    player.physicsBody?.velocity = vector
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
  
  func gameOver(player1Won: Bool) {
    self.gameWon = player1Won
  }
  
  func setCurrentPlayerAt(index: Int) {
    self.viewModel.currentPlayerIndex = index
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
      
      var hostDidWin = false
      switch winningTeam {
      case .team1:
        hostDidWin = teamComponent.team == .team1
      case .team2:
        hostDidWin = teamComponent.team == .team2
      }
      print(hostDidWin ? "Won" : "Lost")
      self.multiplayerNetworking.sendGameEnd(player1Won: hostDidWin)
      
      return true
    }
    
    return false 
  }
}
