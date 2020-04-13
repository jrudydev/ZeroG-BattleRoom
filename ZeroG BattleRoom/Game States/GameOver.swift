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
    MultiplayerNetworkingSnapshot.shared.isSendingSnapshots = false
    
    let background = SKShapeNode(rectOf: UIScreen.main.bounds.size)
    background.fillColor = UIColor.black.withAlphaComponent(20.0)
    background.zPosition = 100
    self.scene.cam!.addChild(background)
    
    let textureName = self.scene.gameWon ? "YouWon" : "GameOver"
    let gameOver = SKSpriteNode(imageNamed: textureName)
    gameOver.zPosition = 101
//    let textureName = self.scene.gameWon ? "YouWon" : "GameOver"
    let texture = SKTexture(imageNamed: textureName)
    let actionSequence = SKAction.sequence([
      SKAction.setTexture(texture),
      SKAction.scale(to: 1.0, duration: 0.25)])

    self.scene.cam!.addChild(gameOver)
    gameOver.run(actionSequence)
    
    let backButton = SKLabelNode(text: "Main Menu")
    backButton.name = AppConstants.ComponentNames.backButtonName
    backButton.fontSize = 30.0
    backButton.position = CGPoint(x: 0.0, y: -100.0)
    backButton.zPosition = 100
    backButton.isUserInteractionEnabled = false
    
    self.scene.cam!.addChild(backButton)
  }
  
  override func willExit(to nextState: GKState) { }

}
