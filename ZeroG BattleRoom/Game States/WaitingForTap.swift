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
  
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    let menuImage = SKSpriteNode(imageNamed: "ZGG")
    menuImage.name = AppConstants.ComponentNames.menuImageName
    menuImage.aspectFillToSize(fillSize: UIScreen.main.bounds.size)
    
    let texture = SKTexture(imageNamed: "ZGG")
    let textureSize = texture.size()
    let screenSize = UIScreen.main.bounds
    let scaledWidth = screenSize.height / textureSize.height * screenSize.width
    
    let diff = (scaledWidth - screenSize.width) / 2
    menuImage.position = CGPoint(x: -diff, y: 0.0)
    
    self.scene.addChild(menuImage)
    
    let fontSize: CGFloat = 80.0
    let secondFontSize: CGFloat = 50.0
    let localLabel = SKLabelNode(text: "Play")
    localLabel.name = AppConstants.ComponentNames.localLabelName
    localLabel.fontSize = fontSize
    localLabel.position = CGPoint(x: localLabel.frame.width / 2, y: fontSize)
    localLabel.position = CGPoint(x: localLabel.position.x - 140, y: localLabel.position.y)
    localLabel.zPosition = 100
    localLabel.isUserInteractionEnabled = false
    self.scene.addChild(localLabel)
    
    let onlineLabel = SKLabelNode(text: "Online Match")
    onlineLabel.name = AppConstants.ComponentNames.onlineLabelName
    onlineLabel.fontSize = secondFontSize
    onlineLabel.position = CGPoint(x: onlineLabel.frame.width / 2, y: 0.0)
    onlineLabel.position = CGPoint(x: onlineLabel.position.x - 120, y: onlineLabel.position.y)
    onlineLabel.zPosition = 100
    onlineLabel.isUserInteractionEnabled = false
    self.scene.addChild(onlineLabel)
    
    let customizeLabel = SKLabelNode(text: "Shop")
    customizeLabel.name = AppConstants.ComponentNames.onlineLabelName
    customizeLabel.fontSize = secondFontSize
    customizeLabel.position = CGPoint(x: customizeLabel.frame.width / 2, y: -fontSize)
    customizeLabel.position = CGPoint(x: customizeLabel.position.x - 120, y: customizeLabel.position.y)
    customizeLabel.zPosition = 100
    customizeLabel.isUserInteractionEnabled = false
    self.scene.addChild(customizeLabel)
    
  }
  
  override func willExit(to nextState: GKState) {
    if nextState is Playing {
      let menuImage = self.scene.childNode(withName: AppConstants.ComponentNames.menuImageName)!
      menuImage.removeFromParent()
      let localLabel = self.scene.childNode(withName: AppConstants.ComponentNames.localLabelName)!
      localLabel.removeFromParent()
      let onlineLabel = self.scene.childNode(withName: AppConstants.ComponentNames.onlineLabelName)!
      onlineLabel.removeFromParent()
      let shopLabel = self.scene.childNode(withName: AppConstants.ComponentNames.onlineLabelName)!
      shopLabel.removeFromParent()
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Playing.Type
  }

}

extension SKSpriteNode {
  func aspectFillToSize(fillSize: CGSize) {
    if self.texture != nil {
      self.size = self.texture!.size()
      
      let verticalRatio = fillSize.height / self.texture!.size().height
      let horizontalRatio = fillSize.width /  self.texture!.size().width
      let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio
      
      self.setScale(scaleRatio)
    }
  }
}
