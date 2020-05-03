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
  
  enum MagnitudeLevel {
    case percent10
    case percent20
    case percent30
    case percent40
    case percent50
    case percent60
    case percent70
    case percent80
    case percent90
    case percent100
    
    static func imageNameFor(fileName: String, percent: CGFloat) -> String {
      switch percent {
      case 0...10: return "\(fileName)-1"
      case 10...20: return "\(fileName)-1"
      case 20...30: return "\(fileName)-2"
      case 30...40: return "\(fileName)-3"
      case 40...50: return "\(fileName)-4"
      case 50...60: return "\(fileName)-5"
      case 60...70: return "\(fileName)-6"
      case 70...80: return "\(fileName)-7"
      case 80...90: return "\(fileName)-8"
      case 90...100: return "\(fileName)-9"
      default: return ""
      }
    }
  }
  
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
  var launchInfo = LaunchInfo()
  
  override init() {
    let size: CGFloat = UIScreen.main.bounds.height
    
    let targetLineNode = SKShapeNode(rectOf: CGSize(width: 0.2, height: size))
    targetLineNode.name = AppConstants.ComponentNames.targetLineName
    targetLineNode.lineWidth = 2.5
    targetLineNode.strokeColor = .gray
    targetLineNode.position = CGPoint(x: 0.0, y: size / 2)
    targetLineNode.zPosition = -3
    
    self.node.addChild(targetLineNode)

    
    let rotationCircleNode = SKShapeNode(rectOf: CGSize(width: 50.0, height: 0.2))
    rotationCircleNode.name = AppConstants.ComponentNames.rotationCircleName
    rotationCircleNode.lineWidth = 2.5
    rotationCircleNode.zPosition = -2
    
    self.node.addChild(rotationCircleNode)
        
    let magnitudePilarNode = SKSpriteNode(imageNamed: "launch-magnitude-1")
    magnitudePilarNode.name = AppConstants.ComponentNames.magnitudePilarName
    magnitudePilarNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
    magnitudePilarNode.zPosition = -1
    
    self.node.addChild(magnitudePilarNode)
    
    super.init()
    
    self.hide()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func showTargetLine() {
    self.node.childNode(withName: AppConstants.ComponentNames.targetLineName)?.alpha = 0.2
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
    if let magnitudePilarNode = self.node.childNode(withName: AppConstants.ComponentNames.magnitudePilarName) as? SKSpriteNode,
      let rotationCircleNode = self.node.childNode(withName: AppConstants.ComponentNames.rotationCircleName) {
      
      let imageName = MagnitudeLevel.imageNameFor(fileName: "launch-magnitude", percent: moveDistance)
      let texture = SKTexture(imageNamed: imageName)
      magnitudePilarNode.texture = texture
      magnitudePilarNode.size = magnitudePilarNode.texture!.size()
      magnitudePilarNode.alpha = directionPercent
      
//      directionNode.yScale = directionPercent
//      let adjustedPosY = AppConstants.Touch.maxSwipeDistance * directionPercent / 2
//      directionNode.position = CGPoint(x: 0.0, y: adjustedPosY)
      
      rotationCircleNode.xScale = rotationPercent
      let adjustedPosX = AppConstants.Touch.maxRotation * rotationPercent / 4
      rotationCircleNode.position = CGPoint(x: isLeftRotation ? adjustedPosX : -1 * adjustedPosX,
                                            y: 0.0)
      rotationCircleNode.alpha = rotationPercent
    }
    
    self.launchInfo.direction = directionVector
    self.launchInfo.directionPercent = directionPercent
    self.launchInfo.rotationPercent = rotationPercent
    self.launchInfo.isLeftRotation = isLeftRotation
  }
  
  func hide() {
    self.node.childNode(withName: AppConstants.ComponentNames.targetLineName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.rotationCircleName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.magnitudePilarName)?.alpha = 0.0
    self.launchInfo.clear()
  }
}
