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
  
  enum Constants {
  
    static let heroThrowPoint: CGPoint = .init(x: 0.0, y: 0.5)
    
  }
  
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
  
  var multiplayerNetworking: MultiplayerNetworking! {
    didSet {
      SnapshotManager.shared.publisher
        .sink { [weak self] elements in
          guard let self = self else { return }
          
          self.multiplayerNetworking.sendSnapshot(elements)
        }
        .store(in: &subscriptions)
      SnapshotManager.shared.scene = self
    }
  }
  
  let audioPlayer: AudioPlayer = {
    let player = AudioPlayer(music: Audio.MusicFiles.level)
    player.sfxVolume = 0.5
    player.musicVolume = 0.5
    return player
  }()
  
  var gameOverStatus: GameOverStatus = .gameLost {
    didSet {
      gameState.enter(GameOver.self)
    }
  }
  var tutorialAction: TutorialAction? {
    guard gameState.currentState is Tutorial else { return nil }
    
    return entityManager.tutorialEntities.first as? TutorialAction
  }
  var currentTutorialStep: Tutorial.Step? { tutorialAction?.currentStep }
  
//  var tutorialDone: Bool = false {
//    didSet {
//      gameState.enter(GameOver.self)
//    }
//  }
//
//  var gameWon: Bool = false {
//    didSet {
//      gameState.enter(GameOver.self)
//    }
//  }
//
//  var connectionDisconnect: Bool = false {
//    didSet {
//      gameState.enter(GameOver.self)
//    }
//  }
//
  
  private let defaultPlayerNames: [String] = ["Player 1", "Musk Bot"]
  
  var lastPinchMagnitude: CGFloat? = nil
  var viewResized: ((CGSize) -> Void)?
  var viewportSize: CGSize = UIScreen.main.bounds.size

  var borderBody: SKPhysicsBody!
  
  var numberOfTouches = 0
  var cam: SKCameraNode?
  var gameMessage: SKLabelNode?
  
  lazy private(set) var hero: General? = { entityManager.hero as? General }()
  lazy private(set) var ghost: General? = { entityManager.playerEntities[1] as? General }()
  
  private var subscriptions = Set<AnyCancellable>()
  private var lastUpdateTime: TimeInterval = 0
  
  override func sceneDidLoad() {
    lastUpdateTime = 0
    
    let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
    borderBody.friction = 0
    self.borderBody = borderBody
    
    entityManager = EntityManager(scene: self)
    
    ShapeFactory.shared.gameScene = self
    setupGameMessage()
    
    gameState.enter(WaitingForTap.self)
    
    NotificationCenter.Publisher(center: .default, name: .motionShake, object: nil)
      .sink(receiveValue: { [weak self] notification in
        guard let self = self else { return }
        guard let hero = self.entityManager.hero as? General,
          let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return }
        
        hero.impactedAt(point: spriteComponent.node.position)
//        multiplayerNetworking
//          .sendImpacted(senderIndex: entityManager.currentPlayerIndex)
        
        spriteComponent.node.randomImpulse()
      })
      .store(in: &subscriptions)
  }
  
  override func update(_ currentTime: TimeInterval) {
    if (lastUpdateTime == 0) {
      lastUpdateTime = currentTime
    }
    let deltaTime = currentTime - lastUpdateTime
    entityManager.update(deltaTime)
    
    lastUpdateTime = currentTime
    gameState.update(deltaTime: currentTime)

    checkForGameOver()
  }
  
  private func checkForGameOver() {
    guard entityManager.isHost else { return }
    guard let winningTeam = entityManager.winningTeam else { return }
    guard let hero = entityManager.hero as? General,
          let teamComponent = hero.component(ofType: TeamComponent.self) else { return }
      
    var localDidWin = false
    switch winningTeam {
    case .team1:
      localDidWin = teamComponent.team == .team1
    case .team2:
      localDidWin = teamComponent.team == .team2
    default: break
    }
    multiplayerNetworking.sendGameEnd(player1Won: localDidWin)
    
    gameOverStatus = localDidWin ? .gameWon : .gameLost
  }
  
}

extension GameScene {
  
  private func setupGameMessage() {
    gameMessage = childNode(withName: "//gameMessage") as? SKLabelNode
    if let gameMessage = gameMessage {
      gameMessage.name = AppConstants.ComponentNames.gameMessageName
      gameMessage.alpha = 0.0
//      gameMessage.run(SKAction.fadeIn(withDuration: 2.0))
    }
  }
  
}

extension GameScene: GameSceneProtocol {
  
  func viewResized(size: CGSize) {
    viewportSize = size
  }
  
}

extension GameScene {
  
  func getPlayerAliasAt(index: Int) -> String {
    guard multiplayerNetworking.playerAliases.count > index else { return defaultPlayerNames[index] }

    return multiplayerNetworking.playerAliases[index]
  }
  
}
