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
  static let resizeView = Notification.Name("resizeView")
}


class GameScene: SKScene {
  
  enum GameOverStatus: Int {
    case tutorialDone
    case gameWon
    case gameLost
    case disconnected
  }
  
  var entityManager: EntityManager!
  var graphs = [String : GKGraph]()
  
  lazy var gameState: GKStateMachine = GKStateMachine(states: [
    WaitingForTap(scene: self),
    Tutorial(scene: self),
    MatchFound(scene: self),
    Playing(scene: self),
    GameOver(scene: self)])
  
  private var lastUpdateTime: TimeInterval = 0
  var lastPinchMagnitude: CGFloat? = nil
  var viewResized: ((CGSize) -> Void)?
  var viewportSize: CGSize = UIScreen.main.bounds.size

  var borderBody: SKPhysicsBody!
  
  var numberOfTouches = 0
  var cam: SKCameraNode?
  var gameMessage: SKLabelNode?
  
  var multiplayerNetworking: MultiplayerNetworking! {
    didSet {
      SnapshotManager.shared.publisher
        .sink { elements in
          self.multiplayerNetworking.sendSnapshot(elements)
        }
        .store(in: &subscriptions)
      SnapshotManager.shared.scene = self
    }
  }
  
  var gameStatus: GameOverStatus = .gameLost {
    didSet {
      self.gameState.enter(GameOver.self)
    }
  }
  
//  var tutorialDone: Bool = false {
//    didSet {
//      self.gameState.enter(GameOver.self)
//    }
//  }
//  
//  var gameWon: Bool = false {
//    didSet {
//      self.gameState.enter(GameOver.self)
//    }
//  }
//  
//  var connectionDisconnect: Bool = false {
//    didSet {
//      self.gameState.enter(GameOver.self)
//    }
//  }
//
  
  internal let audioPlayer: AudioPlayer = {
    let player = AudioPlayer(music: Audio.MusicFiles.level)
    player.sfxVolume = 0.5
    player.musicVolume = 0.5
    return player
  }()
  
  private var subscriptions = Set<AnyCancellable>()
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    borderBody.friction = 0
    self.borderBody = borderBody
    
    self.entityManager = EntityManager(scene: self)
    
    ShapeFactory.shared.gameScene = self
    self.setupGameMessage()
    
    self.gameState.enter(WaitingForTap.self)
    
    NotificationCenter.Publisher(center: .default, name: .motionShake, object: nil)
      .sink(receiveValue: { [weak self] notification in
        guard let self = self else { return }
        guard let hero = self.entityManager.hero as? General,
          let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return }
        
        hero.impactedAt(point: spriteComponent.node.position)
//        self.multiplayerNetworking
//          .sendImpacted(senderIndex: self.entityManager.currentPlayerIndex)
        
        spriteComponent.node.randomImpulse()
      })
      .store(in: &subscriptions)
  }
  
  override func update(_ currentTime: TimeInterval) {
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }
    let deltaTime = currentTime - self.lastUpdateTime
    self.entityManager.update(deltaTime)
    
    self.lastUpdateTime = currentTime
    self.gameState.update(deltaTime: currentTime)

    self.checkForGameOver()
  }
  
  private func checkForGameOver() {
    if self.entityManager.currentPlayerIndex == 0 {
      guard self.entityManager.playerEntites.count > 0 else { return }
      guard let winningTeam = self.entityManager.winningTeam else { return }
      
      if let hero = self.entityManager.hero as? General,
        let teamComponent = hero.component(ofType: TeamComponent.self) {
        
        var localDidWin = false
        switch winningTeam {
        case .team1:
          localDidWin = teamComponent.team == .team1
        case .team2:
          localDidWin = teamComponent.team == .team2
        default: break
        }
        self.multiplayerNetworking.sendGameEnd(player1Won: localDidWin)
        
        self.gameStatus = localDidWin ? .gameWon : .gameLost
      }
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
    self.gameStatus = .disconnected
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
  
  func movePlayerAt(index: Int,
                    position: CGPoint,
                    rotation: CGFloat,
                    velocity: CGVector,
                    angularVelocity: CGFloat,
                    wasLaunch: Bool) {
    if let player = self.entityManager.playerEntites[index] as? General,
      let spriteComponent = player.component(ofType: SpriteComponent.self),
      let physicsComponent = player.component(ofType: PhysicsComponent.self),
      let impulseComponent = player.component(ofType: ImpulseComponent.self) {
       
      spriteComponent.node.zRotation = rotation
      spriteComponent.node.position = position

      player.switchToState(.moving)
      if wasLaunch,
        let beamComponent = player.occupiedPanel?.component(ofType: BeamComponent.self) {
        
        beamComponent.isOccupied = false
        player.resetBeamTimer()
      } else {
        guard !impulseComponent.isOnCooldown else { return }
  
        impulseComponent.isOnCooldown = true
      }
      
      
      DispatchQueue.main.async {
        physicsComponent.physicsBody.velocity = velocity
        physicsComponent.physicsBody.angularVelocity = angularVelocity
      }
    }
  }
  
  func syncPlayerAt(index: Int,
                    position: CGPoint,
                    rotation: CGFloat,
                    velocity: CGVector,
                    angularVelocity: CGFloat,
                    resourceIndecies: [Int]) {
    if let player = self.entityManager.playerEntites[index] as? General,
      let spriteComponent = player.component(ofType: SpriteComponent.self),
      let physicsComponent = player.component(ofType: PhysicsComponent.self) {
      
      spriteComponent.node.position = position
      spriteComponent.node.zRotation = rotation
      physicsComponent.physicsBody.velocity = velocity
      physicsComponent.physicsBody.angularVelocity = angularVelocity
    }
  }
  
//  func moveResourceAt(index: Int,
//                      position: CGPoint,
//                      rotation: CGFloat,
//                      velocity: CGVector,
//                      angularVelocity: CGFloat) {
//    if let package = self.entityManager.resourcesEntities[index] as? Package,
//      let shapeComponent = package.component(ofType: ShapeComponent.self),
//      let physicsComponent = package.component(ofType: PhysicsComponent.self) {
//
//      shapeComponent.node.position = position
//      shapeComponent.node.zRotation = rotation
//      physicsComponent.physicsBody.velocity = velocity
//      physicsComponent.physicsBody.angularVelocity = angularVelocity
//    }
//  }
  
  func syncResourceAt(index: Int,
                      position: CGPoint,
                      rotation: CGFloat,
                      velocity: CGVector,
                      angularVelocity: CGFloat) {
    if let package = self.entityManager.resourcesEntities[index] as? Package,
      let shapeComponent = package.component(ofType: ShapeComponent.self),
      let physicsComponent = package.component(ofType: PhysicsComponent.self) {
      
      shapeComponent.node.position = position
      shapeComponent.node.zRotation = rotation
      physicsComponent.physicsBody.velocity = velocity
      physicsComponent.physicsBody.angularVelocity = angularVelocity
    }
  }
  
  func syncPlayerResources(players: MultiplayerNetworking.SnapshotElementGroup) {
    for (idx, playerSnap) in players.enumerated() {
      if let player = self.entityManager.playerEntites[idx] as? General,
        let handsComponent = player.component(ofType: HandsComponent.self),
        let deliveredComponent = player.component(ofType: DeliveredComponent.self) {
        
        // Check the left hand
        if playerSnap.resourceIndecies.count >= 1 {
          let index = playerSnap.resourceIndecies[0]
          let heldResource = self.entityManager.resourcesEntities[index] as! Package
          
          if let leftHandSlot = handsComponent.leftHandSlot {
            if heldResource != leftHandSlot {
              handsComponent.release(resource: leftHandSlot)
              handsComponent.grab(resource: heldResource)
            }
          } else {
            handsComponent.grab(resource: heldResource)
          }
        } else if let leftHandSlot = handsComponent.leftHandSlot {
          handsComponent.release(resource: leftHandSlot)
        }
        
        // Check the right hand
        if playerSnap.resourceIndecies.count >= 2 {
          let index = playerSnap.resourceIndecies[1]
          let heldResource = self.entityManager.resourcesEntities[index] as! Package
          
          if let rightHandSlot = handsComponent.rightHandSlot {
            if heldResource != rightHandSlot {
              handsComponent.release(resource: rightHandSlot)
              handsComponent.grab(resource: heldResource)
            }
          } else {
            handsComponent.grab(resource: heldResource)
          }
        } else if let rightHandSlot = handsComponent.rightHandSlot {
          handsComponent.release(resource: rightHandSlot)
        }
        
        // Check scored resources
        var scoredResources = Set<Package>()
        for index in playerSnap.scoredResourceIndecies {
          let resource = self.entityManager.resourcesEntities[index] as! Package
          
          guard let resourceShapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
          
          if self.entityManager.isScored(resource: resource) {
            resourceShapeComponent.node.removeFromParent()
          }
          
          scoredResources.insert(resource)
        }
        
        deliveredComponent.resources = scoredResources
      }
    }
  }
  
  func syncResources(resources: MultiplayerNetworking.SnapshotElementGroup) {
    for x in self.entityManager.resourcesEntities.count..<resources.count {
      self.entityManager.spawnResource(position: resources[x].position,
                                       velocity: resources[x].velocity)
    }
  }
  
//  func impactPlayerAt(senderIndex: Int) {
//    if let hero = self.entityManager.playerEntites[senderIndex] as? General,
//      let spriteComponent = hero.component(ofType: SpriteComponent.self),
//      let heroHandsComponent = hero.component(ofType: HandsComponent.self),
//      !heroHandsComponent.isImpacted {
//       
//      print("Hero at index: \(senderIndex) impacted!!!!")
//      hero.impactedAt(point: spriteComponent.node.position)
//    }
//  }
//  
//  func grabResourceAt(index: Int, playerIndex: Int, senderIndex: Int) {
//    let senderEntity = self.entityManager.playerEntites[senderIndex]
//    let playerEntity = self.entityManager.playerEntites[playerIndex]
//    
//    guard let playerHandsComponent = playerEntity.component(ofType: HandsComponent.self),
//      let resource = self.entityManager.resourcesEntities[index] as? Package,
//      let resourceShapeComponent = resource.component(ofType: ShapeComponent.self),
//      !playerHandsComponent.isHolding(shapeComponent: resourceShapeComponent) else { return }
//    
//    if senderEntity == self.entityManager.playerEntites[0] {
//      for player in self.entityManager.playerEntites {
//        guard player != playerEntity else { continue }
//        guard let handsComponent = player.component(ofType: HandsComponent.self) else { continue }
//
//        if handsComponent.isHolding(shapeComponent: resourceShapeComponent) {
//          // If so release and send correction back to client
//          handsComponent.release(resource: resource)
//
////          self.multiplayerNetworking.sendAssignResource(index: index, playerIndex: playerIndex)
//
//          return
//        }
//      }
//    } else {
//      for player in self.entityManager.playerEntites {
//        guard player != playerEntity else { continue }
//        guard let handsComponent = player.component(ofType: HandsComponent.self) else { continue }
//
//        if handsComponent.isHolding(shapeComponent: resourceShapeComponent) {
//          handsComponent.release(resource: resource, point: resourceShapeComponent.node.position)
//          break
//        }
//      }
//
//    }
//    playerHandsComponent.grab(resource: resource)
//  }
//  
//  func assignResourceAt(index: Int, playerIndex: Int) {
//    guard let hero = self.entityManager.hero as? General,
//      let heroHandscomponent = hero.component(ofType: HandsComponent.self),
//      let player = self.entityManager.playerEntites[playerIndex] as? General,
//      let playerHandsComponent = player.component(ofType: HandsComponent.self),
//      let package = self.entityManager.resourcesEntities[index] as? Package else { return }
//    
//    heroHandscomponent.release(resource: package)
//    playerHandsComponent.grab(resource: package)
//  }
//  
//  func syncWallAt(index: Int, isOccupied: Bool) {
//    guard let beamComponent = self.entityManager.wallEntities[index].component(ofType: BeamComponent.self) else { return }
//    
//    beamComponent.isOccupied = isOccupied
//  }
  
  func gameOver(player1Won: Bool) {
    self.gameStatus = !player1Won ? .gameWon : .gameLost
  }
  
  func setCurrentPlayerAt(index: Int) {
    self.entityManager.currentPlayerIndex = index
    self.gameState.enter(MatchFound.self)
  
    SnapshotManager.shared.isSendingSnapshots = true
  }
}

extension GameScene: GameSceneProtocol {
  func viewResized(size: CGSize) {
    self.viewportSize = size
  }
}

extension GameScene {
  func getPlayerAliasAt(index: Int) -> String {
    if index == 0 {
      if self.multiplayerNetworking.playerAliases.count > 0 {
        return self.multiplayerNetworking.playerAliases[0]
      } else {
        return "Player 1"
      }
    }
    
    if index == 1 {
      if self.multiplayerNetworking.playerAliases.count > 1 {
        return self.multiplayerNetworking.playerAliases[1]
      } else {
        return "MuskBot"
      }
    }
    
    return "No Name"
  }
}
