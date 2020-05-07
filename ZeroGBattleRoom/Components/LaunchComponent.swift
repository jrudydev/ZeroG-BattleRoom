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
    var lastTouchBegan: CGPoint?
    var direction: CGVector?
    var directionPercent: CGFloat?
    var rotationPercent: CGFloat?
    var isLeftRotation: Bool?
    
    mutating func clear() {
      self.lastTouchBegan = nil
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

    let roationCircleNode = SKSpriteNode(imageNamed: "launch-rotation-1")
    roationCircleNode.name = AppConstants.ComponentNames.rotationCircleName
    roationCircleNode.zPosition = -2
    
    self.node.addChild(roationCircleNode)
    
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
  
  func update(touchPosition: CGPoint) {
    guard let hero = self.entity as? General,
      let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
      let targetPosition = self.launchInfo.lastTouchBegan else { return }
    
    let heroPosition = heroSpriteComponent.node.position
    let heroRotation = heroSpriteComponent.node.zRotation
    let directionVector = heroPosition.vectorTo(point: targetPosition)
    let directionRotation = directionVector.rotation - heroRotation
    
    let intersect = self.getIntersect(heroPosition: heroPosition,
                                      targetPosition: targetPosition,
                                      touchPosition: touchPosition)
    let isLeftRotation = self.getIsLeftRotation(heroPosition: heroPosition,
                                                targetPosition: targetPosition,
                                                touchPosition: touchPosition)
    let halfMagnitudeVector = self.getHalfMagnitudePos(vector: directionVector,
                                                       targetPosition: targetPosition)
    let launchVector = intersect.vectorTo(point: halfMagnitudeVector)
    let rotationVector = touchPosition.vectorTo(point: intersect)
    
    // Caculate launch distance
    let moveDistance = min(AppConstants.Touch.maxSwipeDistance, launchVector.length())
    let directionPercent = moveDistance / 100
    
    // Caculate launch rotation
    let rotationDistance = min(AppConstants.Touch.maxRotation, rotationVector.length())
    let rotationPercent = rotationDistance / 100
    
    // Update Node
    self.node.zRotation = directionRotation
    if let magnitudePilarNode = self.node.childNode(
        withName: AppConstants.ComponentNames.magnitudePilarName) as? SKSpriteNode,
      let rotationCircleNode = self.node.childNode(
        withName: AppConstants.ComponentNames.rotationCircleName) as? SKSpriteNode {
      
      let magnitudeImage = MagnitudeLevel.imageNameFor(fileName: "launch-magnitude", percent: moveDistance)
      magnitudePilarNode.setTexture(imageNamed: magnitudeImage)
      magnitudePilarNode.alpha = 1.0
//      magnitudePilarNode.alpha = directionPercent
          
      let rotationImage = MagnitudeLevel.imageNameFor(fileName: "launch-rotation", percent: rotationDistance)
      rotationCircleNode.setTexture(imageNamed: rotationImage)
      rotationCircleNode.alpha = 1.0
//      rotationCircleNode.alpha = rotationPercent
      rotationCircleNode.xScale = isLeftRotation ? 1.0 : -1.0
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

extension LaunchComponent {
  private func getHalfMagnitudePos(vector: CGVector, targetPosition: CGPoint) -> CGPoint {
    let halfMaxSwipeDist = AppConstants.Touch.maxSwipeDistance / 2
    let adjustmentVector = vector.reversed().normalized() * halfMaxSwipeDist
    return CGPoint(x: targetPosition.x + adjustmentVector.dx,
                   y: targetPosition.y + adjustmentVector.dy)
  }
  
  private func getIntersect(heroPosition: CGPoint,
                            targetPosition: CGPoint,
                            touchPosition: CGPoint) -> CGPoint {
    var intersect: CGPoint = .zero
    if heroPosition.x == targetPosition.x {
      // vertical slope
      intersect = targetPosition
    } else if heroPosition.y == targetPosition.y {
      // horizontal slope
      intersect = targetPosition
    } else {
      let touchSlope = heroPosition.slopeTo(point: targetPosition)
      intersect = targetPosition.intersection(m1: touchSlope, P2: touchPosition, m2: -1 / touchSlope)
    }
    
    return intersect
  
  }
  private func getIsLeftRotation(heroPosition: CGPoint,
                                 targetPosition: CGPoint,
                                 touchPosition: CGPoint) -> Bool {
    var isLeft = false
    if heroPosition.x == targetPosition.x {
      // vertical slope
      if heroPosition.y < targetPosition.y {
        isLeft = touchPosition.x < targetPosition.x
      } else if heroPosition.y > targetPosition.y {
        isLeft = touchPosition.x > targetPosition.x
      }
       
    } else if heroPosition.y == targetPosition.y {
      // horizontal slope
      if heroPosition.x < targetPosition.x {
        isLeft = touchPosition.y < targetPosition.y
      } else if heroPosition.x > targetPosition.x {
        isLeft = touchPosition.y > targetPosition.y
      }
    } else {
      let touchSlope = heroPosition.slopeTo(point: targetPosition)
     
      if heroPosition.x > targetPosition.x {
        isLeft = touchPosition.isAbove(point: targetPosition, slope: touchSlope)
      } else if heroPosition.x < targetPosition.x {
        isLeft = !touchPosition.isAbove(point: targetPosition, slope: touchSlope)
      }
    }
  
    return isLeft
  }
}

extension CGPoint {
  func isAbove(point: CGPoint, slope: CGFloat) -> Bool {
    guard slope != 0 || slope != CGFloat.infinity else { return false }
    
    // PointSlope Line Formula: y = xm + b
    // b = y - xm
    let b = point.y - point.x * slope
  
    // Check if point is above with this formula: y > xm + b
    return self.y > self.x * slope + b
  }
}

extension SKSpriteNode {
  func setTexture(imageNamed: String) {
    let magnitudeTexture = SKTexture(imageNamed: imageNamed)
    self.texture = magnitudeTexture
    self.size = self.texture!.size()
  }
}
