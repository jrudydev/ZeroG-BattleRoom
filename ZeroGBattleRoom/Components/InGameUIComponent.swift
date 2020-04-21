//
//  UIComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/20/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class InGameUIComponent: GKComponent {
  var node: SKNode
  var viewport: CGSize
  
  private var normalizedPosition: CGPoint
  
  var scale: CGFloat {
    let boundingBox = AppConstants.Layout.boundarySize
    let extra = viewport.height - UIScreen.main.bounds.size.height
    let total = boundingBox.height - UIScreen.main.bounds.size.height
    let percentIncrease = extra / total
    let screenSizeDifference = boundingBox.height / UIScreen.main.bounds.size.height
    
    return 1 + screenSizeDifference * percentIncrease
  }
  
  init(node: SKNode, viewport: CGSize, normalizedPosition: CGPoint) {
    self.node = node
    self.viewport = viewport
    self.normalizedPosition = normalizedPosition
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    self.node.setScale(self.scale)
    
    let initialScreenSize = UIScreen.main.bounds.size
    let viewportRatio = self.viewport.width / self.viewport.height
    let initialScreenRatio = initialScreenSize.width / initialScreenSize.height
    let adjustment = (viewportRatio - initialScreenRatio) * AppConstants.Layout.boundarySize.height
    
    let posX = self.normalizedPosition.x * self.viewport.width - self.viewport.width / 2
    let posY = -self.normalizedPosition.y * self.viewport.height + self.viewport.height / 2 + adjustment * viewportRatio
    self.node.position = CGPoint(x: posX, y: posY)
  }
}
