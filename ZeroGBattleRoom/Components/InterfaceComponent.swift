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
  let elements: [SKNode]
  private var startingPositions = [CGPoint]()
  
  var viewport: CGSize
  
  init(elements: [SKNode]) {
    self.node = SKNode()
    self.node.name = AppConstants.ComponentNames.uiView
    self.viewport = InterfaceComponent.screenSize
    self.elements = elements
    
    super.init()
    
    for element in elements {
      self.startingPositions.append(element.position)
      self.node.addChild(element)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    for (idx, element) in elements.enumerated() {
      let widthScale = self.viewport.width / InterfaceComponent.screenSize.width
      let heightScale = self.viewport.height / InterfaceComponent.screenSize.height
      let boundryRatio = AppConstants.Layout.boundarySize.width / AppConstants.Layout.boundarySize.height
      let screenRatio = InterfaceComponent.screenSize.width / InterfaceComponent.screenSize.height
 =
      let scale = boundryRatio < screenRatio ? heightScale : widthScale
      let newHeight = self.startingPositions[idx].y * scale
      let newWidth = self.startingPositions[idx].x * scale
      element.position = CGPoint(x: newWidth, y: newHeight)
      element.setScale(scale)
    }
  }
}
