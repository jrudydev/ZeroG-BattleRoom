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
  
  struct LaunchInfo {
    var lastTouchDown: CGPoint?
    var direction: CGVector?
    var directionPercent: CGFloat?
    var rotationPercent: CGFloat?
    var isLeftRotation: Bool?
    
    mutating func clear() {
      self.lastTouchDown = nil
      self.direction = nil
      self.directionPercent = nil
      self.rotationPercent = nil
      self.isLeftRotation = nil
    }
  }
  
  var node = SKNode()
  var directionNode: SKShapeNode
  var rotationNode: SKShapeNode
  
  var launchInfo = LaunchInfo()
  
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
    
    self.hide()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(directionVector: CGVector,
              moveVector: CGVector,
              rotationVector: CGVector,
              directionRotation: CGFloat,
              isLeftRotation: Bool) {
    // Caculate launch distance
    let moveDistance = min(AppConstants.Touch.maxSwipeDistance, moveVector.length())
    let directionPercent = moveDistance / 100
    
    // Caculate launch rotation
    let rotationDistance = min(AppConstants.Touch.maxRotation, rotationVector.length())
    let rotationPercent = rotationDistance / 100
    
    // Update Node
    self.node.zRotation = directionRotation
    if let directionNode = self.node.childNode(withName: AppConstants.ComponentNames.directionNode),
      let angleNode = self.node.childNode(withName: AppConstants.ComponentNames.angleNode){
      
      directionNode.yScale = directionPercent
      let adjustedPosY = AppConstants.Touch.maxSwipeDistance * directionPercent / 2
      directionNode.position = CGPoint(x: 0.0, y: adjustedPosY)
      directionNode.alpha = directionPercent
      
      angleNode.xScale = rotationPercent
      let adjustedPosX = AppConstants.Touch.maxRotation * rotationPercent / 4
      angleNode.position = CGPoint(x: isLeftRotation ? adjustedPosX : -1 * adjustedPosX,
                                   y: 0.0)
      angleNode.alpha = rotationPercent
    }
    
    self.launchInfo.direction = directionVector
    self.launchInfo.directionPercent = directionPercent
    self.launchInfo.rotationPercent = rotationPercent
    self.launchInfo.isLeftRotation = isLeftRotation
  }
  
  func hide() {
    self.directionNode.alpha = 0.0
    self.rotationNode.alpha = 0.0
    self.launchInfo.clear()
  }
}
