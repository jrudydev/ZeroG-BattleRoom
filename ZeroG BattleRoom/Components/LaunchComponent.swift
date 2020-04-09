//
//  LaunchComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/8/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class LaunchComponent: GKComponent {
  var node = SKNode()
  var directionNode: SKShapeNode
  var rotationNode: SKShapeNode
  
  override init() {
    self.directionNode = SKShapeNode(rectOf: CGSize(width: 0.2, height: 100.0))
    self.directionNode.name = AppConstants.ComponentNames.directionNode
    self.directionNode.lineWidth = 2.5
    self.directionNode.strokeColor = .yellow
    self.directionNode.position = CGPoint(x: 0.0, y: 50.0)
    self.directionNode.zPosition = 100
    
    self.node.addChild(self.directionNode)
    
    self.rotationNode = SKShapeNode(rectOf: CGSize(width: 50.0, height: 0.2))
    self.rotationNode.name = AppConstants.ComponentNames.angleNode
    self.rotationNode.lineWidth = 2.5
    self.rotationNode.zPosition = 100
    
    self.node.addChild(self.rotationNode)
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
