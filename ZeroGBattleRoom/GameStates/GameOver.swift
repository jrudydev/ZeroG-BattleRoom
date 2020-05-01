//
//  GameOver.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit

class GameOver: GKState {
  
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    self.scene.physicsWorld.speed = 0.0
    SnapshotManager.shared.isSendingSnapshots = false
    
    let background = SKShapeNode(rectOf: UIScreen.main.bounds.size)
    background.fillColor = UIColor.black.withAlphaComponent(20.0)
    background.strokeColor = UIColor.black
    background.zPosition = 100
    self.scene.cam!.addChild(background)
    
    let actionSequence = SKAction.sequence([
      SKAction.scale(by: 0.0, duration: 0.0),
      SKAction.scale(to: 1.0, duration: 0.25)])
    if self.scene.gameStatus == .tutorialDone {
      let disconnectedLabel = SKLabelNode(text: "Disconnected")
      disconnectedLabel.name = AppConstants.ComponentNames.gameOverLabel
      disconnectedLabel.fontSize = 50.0
      disconnectedLabel.zPosition = SpriteZPosition.menuLabel.rawValue
      
      self.scene.cam!.addChild(disconnectedLabel)
      disconnectedLabel.run(actionSequence)
    } else if self.scene.gameStatus == .tutorialDone {
      let tutorialCompleteLabel = SKLabelNode(text: "Tutorial Complete")
      tutorialCompleteLabel.name = AppConstants.ComponentNames.gameOverLabel
      tutorialCompleteLabel.fontSize = 50.0
      tutorialCompleteLabel.zPosition = SpriteZPosition.menuLabel.rawValue
      
      self.scene.cam!.addChild(tutorialCompleteLabel)
      tutorialCompleteLabel.run(actionSequence)
    } else {
      let textureName = (self.scene.gameStatus == .gameWon) ? "YouWon" : "GameOver"
      let gameOver = SKSpriteNode(imageNamed: textureName)
      gameOver.zPosition = SpriteZPosition.menuLabel.rawValue
      
      self.scene.cam!.addChild(gameOver)
      gameOver.run(actionSequence)
    }
    
    let mainMenuButton = SKLabelNode(text: "Main Menu")
    mainMenuButton.name = AppConstants.ComponentNames.backButtonName
    mainMenuButton.fontSize = 30.0
    mainMenuButton.position = CGPoint(x: 0.0, y: -100.0)
    mainMenuButton.zPosition = 101
    mainMenuButton.isUserInteractionEnabled = false
    
    self.scene.cam!.addChild(mainMenuButton)
  }
  
  override func willExit(to nextState: GKState) { }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return false
  }

}
