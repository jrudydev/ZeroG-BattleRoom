//
//  WaitingForTap.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit

class WaitingForTap: GKState {
  
  static let menuFontSize: CGFloat = 50.0
  
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    let menuImage = SKSpriteNode(imageNamed: "ZGG")
    menuImage.name = AppConstants.ComponentNames.menuImageName
    menuImage.aspectFillToSize(fillSize: UIScreen.main.bounds.size)
    
    let widthDiff = (menuImage.size.width - UIScreen.main.bounds.width) / 2
    menuImage.position = CGPoint(x: menuImage.position.x +  widthDiff, y: menuImage.position.y)
    
    self.scene.addChild(menuImage)
    
    let tutorialLabel = SKLabelNode(text: "Tutorial")
    tutorialLabel.name = AppConstants.ComponentNames.tutorialLabelName
    tutorialLabel.fontSize = WaitingForTap.menuFontSize
    tutorialLabel.position = CGPoint(x: tutorialLabel.frame.width / 2, y: WaitingForTap.menuFontSize*2)
    tutorialLabel.position = CGPoint(x: tutorialLabel.position.x - 120, y: tutorialLabel.position.y)
    tutorialLabel.zPosition = SpriteZPosition.menu.rawValue
    tutorialLabel.isUserInteractionEnabled = false
    self.scene.addChild(tutorialLabel)
    
    let localLabel = SKLabelNode(text: "Versus")
    localLabel.name = AppConstants.ComponentNames.localLabelName
    localLabel.fontSize = WaitingForTap.menuFontSize
    localLabel.position = CGPoint(x: localLabel.frame.width / 2, y: WaitingForTap.menuFontSize)
    localLabel.position = CGPoint(x: localLabel.position.x - 120, y: localLabel.position.y)
    localLabel.zPosition = SpriteZPosition.menu.rawValue
    localLabel.isUserInteractionEnabled = false
    self.scene.addChild(localLabel)
    
    let onlineLabel = SKLabelNode(text: "Online")
    onlineLabel.name = AppConstants.ComponentNames.onlineLabelName
    onlineLabel.fontSize = WaitingForTap.menuFontSize
    onlineLabel.position = CGPoint(x: onlineLabel.frame.width / 2, y: 0.0)
    onlineLabel.position = CGPoint(x: onlineLabel.position.x - 120, y: onlineLabel.position.y)
    onlineLabel.zPosition = SpriteZPosition.menu.rawValue
    onlineLabel.isUserInteractionEnabled = false
    self.scene.addChild(onlineLabel)
    
    let customizeLabel = SKLabelNode(text: "Shop")
    customizeLabel.name = AppConstants.ComponentNames.onlineLabelName
    customizeLabel.fontSize = WaitingForTap.menuFontSize
    customizeLabel.position = CGPoint(x: customizeLabel.frame.width / 2, y: -WaitingForTap.menuFontSize)
    customizeLabel.position = CGPoint(x: customizeLabel.position.x - 120, y: customizeLabel.position.y)
    customizeLabel.zPosition = SpriteZPosition.menu.rawValue
    customizeLabel.isUserInteractionEnabled = false
    self.scene.addChild(customizeLabel)
  }
  
  override func willExit(to nextState: GKState) {
    let menuImage = self.scene.childNode(withName: AppConstants.ComponentNames.menuImageName)
    menuImage?.removeFromParent()
    let tutorialLabel = self.scene.childNode(withName: AppConstants.ComponentNames.tutorialLabelName)
    tutorialLabel?.removeFromParent()
    let localLabel = self.scene.childNode(withName: AppConstants.ComponentNames.localLabelName)
    localLabel?.removeFromParent()
    let onlineLabel = self.scene.childNode(withName: AppConstants.ComponentNames.onlineLabelName)
    onlineLabel?.removeFromParent()
    let shopLabel = self.scene.childNode(withName: AppConstants.ComponentNames.onlineLabelName)
    shopLabel?.removeFromParent()
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is MatchFound.Type || stateClass is Tutorial.Type
  }

}
