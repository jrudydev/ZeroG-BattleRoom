//
//  Disconnected.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/14/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit

class Disconnected: GKState {
  
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
    
    
    let disconnectedLabel = SKLabelNode(text: "Disconnected")
    disconnectedLabel.name = AppConstants.ComponentNames.disconnectedLabel
    disconnectedLabel.fontSize = 50.0
    disconnectedLabel.zPosition = 101
    
    self.scene.cam!.addChild(disconnectedLabel)
    
    let mainMenuButton = SKLabelNode(text: "Main Menu")
    mainMenuButton.name = AppConstants.ComponentNames.backButtonName
    mainMenuButton.fontSize = 30.0
    mainMenuButton.position = CGPoint(x: 0.0, y: -100.0)
    mainMenuButton.zPosition = 101
    mainMenuButton.isUserInteractionEnabled = false
    
    self.scene.cam!.addChild(mainMenuButton)
  }
  
  override func willExit(to nextState: GKState) {

  }
  
}
