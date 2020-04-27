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
    
    let textureName = self.scene.gameWon ? "YouWon" : "GameOver"
    let gameOver = SKSpriteNode(imageNamed: textureName)
    gameOver.zPosition = 101
    // TODO: Fix this animation
//    let textureName = self.scene.gameWon ? "YouWon" : "GameOver"
    let texture = SKTexture(imageNamed: textureName)
    let actionSequence = SKAction.sequence([
      SKAction.setTexture(texture),
      SKAction.scale(to: 1.0, duration: 0.25)])

    self.scene.cam!.addChild(gameOver)
    gameOver.run(actionSequence)
    
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
