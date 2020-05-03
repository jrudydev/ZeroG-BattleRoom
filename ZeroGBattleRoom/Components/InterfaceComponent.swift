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


class InterfaceComponent: GKComponent {
  static let screenSize = UIScreen.main.bounds.size
  
  let node: SKNode
  private var startingPosition: CGPoint
  
  var viewport: CGSize
  
  init(node: SKNode) {
    self.node = node
    self.startingPosition = node.position
    self.viewport = InterfaceComponent.screenSize
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    let widthScale = self.viewport.width / InterfaceComponent.screenSize.width
    let heightScale = self.viewport.height / InterfaceComponent.screenSize.height
    let boundryRatio = AppConstants.Layout.boundarySize.width / AppConstants.Layout.boundarySize.height
    let screenRatio = InterfaceComponent.screenSize.width / InterfaceComponent.screenSize.height

    let scale = boundryRatio < screenRatio ? heightScale : widthScale
    let newHeight = self.startingPosition.y * scale
    let newWidth = self.startingPosition.x * scale
    self.node.position = CGPoint(x: newWidth, y: newHeight)
    self.node.setScale(scale)
  }
}
