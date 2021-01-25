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
    scene.physicsWorld.speed = 0.0
    SnapshotManager.shared.isSendingSnapshots = false
    
    let background = SKShapeNode(rectOf: UIScreen.main.bounds.size)
    background.fillColor = UIColor.black.withAlphaComponent(20.0)
    background.strokeColor = UIColor.black
    background.zPosition = 100
    scene.cam!.addChild(background)
    
    let titlePosition = CGPoint(x: 0.0, y: UIScreen.main.bounds.height * 0.2)
    let actionSequence = SKAction.sequence([
      SKAction.scale(by: 0.0, duration: 0.0),
      SKAction.scale(to: 1.0, duration: 0.25)])
    if scene.gameOverStatus == .disconnected {
      let disconnectedSprite = SKSpriteNode(imageNamed: "disconnected")
      disconnectedSprite.position = titlePosition
      disconnectedSprite.zPosition = SpriteZPosition.menuLabel.rawValue
      
      let labelWidth = UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.2
      let labelHeight = labelWidth / disconnectedSprite.size.width * disconnectedSprite.size.height
      disconnectedSprite.size = CGSize(width: labelWidth, height: labelHeight)
      
      scene.cam!.addChild(disconnectedSprite)
      disconnectedSprite.run(actionSequence)
    } else if scene.gameOverStatus == .tutorialDone {
      let tutorialDoneSprite = SKSpriteNode(imageNamed: "tutorialdone")
      tutorialDoneSprite.position = titlePosition
      tutorialDoneSprite.zPosition = SpriteZPosition.menuLabel.rawValue
      
      let labelWidth = UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.2
      let labelHeight = labelWidth / tutorialDoneSprite.size.width * tutorialDoneSprite.size.height
      tutorialDoneSprite.size = CGSize(width: labelWidth, height: labelHeight)

      scene.cam!.addChild(tutorialDoneSprite)
      tutorialDoneSprite.run(actionSequence)
    } else {
      let textureName = (scene.gameOverStatus == .gameWon) ? "gamewon" : "gameover"
      let gameOverSprite = SKSpriteNode(imageNamed: textureName)
      gameOverSprite.position = titlePosition
      gameOverSprite.zPosition = SpriteZPosition.menuLabel.rawValue
      
      let labelWidth = UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.2
      let labelHeight = labelWidth / gameOverSprite.size.width * gameOverSprite.size.height
      gameOverSprite.size = CGSize(width: labelWidth, height: labelHeight)
      
      scene.cam!.addChild(gameOverSprite)
      gameOverSprite.run(actionSequence)
    }
    
    let mainMenuButton = SKLabelNode(text: "Main Menu")
    mainMenuButton.name = AppConstants.ButtonNames.backButtonName
    mainMenuButton.fontSize = 30.0
    mainMenuButton.position = CGPoint(x: 0.0, y: -100.0)
    mainMenuButton.zPosition = 101
    mainMenuButton.isUserInteractionEnabled = false
    
    scene.cam!.addChild(mainMenuButton)
  }
  
  override func willExit(to nextState: GKState) { }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return false
  }

}
