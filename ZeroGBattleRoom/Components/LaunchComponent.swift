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
  
  static let targetLineAlpha: CGFloat = 0.5
  static let targetNodeWidth: CGFloat = 15.0
  
  var node = SKNode()
  var launchInfo = LaunchInfo()
  
  override init() {
    let size: CGFloat = UIScreen.main.bounds.height
    
    let launchLineNode = SKShapeNode(circleOfRadius: AppConstants.Touch.maxSwipeDistance)
    launchLineNode.name = AppConstants.ComponentNames.launchLineName
    launchLineNode.lineWidth = 2.5
    launchLineNode.strokeColor = .gray
    launchLineNode.zPosition = -1
    launchLineNode.alpha = 0.0
    self.node.addChild(launchLineNode)
    
    let targetLineNode = SKShapeNode(rectOf: CGSize(width: 0.2, height: size))
    targetLineNode.name = AppConstants.ComponentNames.targetLineName
    targetLineNode.lineWidth = 2.5
    targetLineNode.strokeColor = .gray
    targetLineNode.position = CGPoint(x: 0.0, y: size / 2)
    targetLineNode.zPosition = -1
    self.node.addChild(targetLineNode)
    
    let targetBaseLineNode = SKShapeNode(rectOf: CGSize(width: Self.targetNodeWidth,
                                                        height: 0.0))
    targetBaseLineNode.name = AppConstants.ComponentNames.targetBaseLineName
    targetBaseLineNode.lineWidth = 2.5
    targetBaseLineNode.strokeColor = .gray
    targetBaseLineNode.zPosition = -1
    self.node.addChild(targetBaseLineNode)
    
    let targetMidCircleNode = SKShapeNode(circleOfRadius: Self.targetNodeWidth / 2)
    targetMidCircleNode.name = AppConstants.ComponentNames.targetMidCircleName
    targetMidCircleNode.lineWidth = 2.5
    targetMidCircleNode.strokeColor = .gray
    targetMidCircleNode.zPosition = -1
    self.node.addChild(targetMidCircleNode)
    
    let chevronSize = CGSize(width: Self.targetNodeWidth * 0.8, height: 0.0)
    
    let targetLeftChecvronNode = SKShapeNode(rectOf: chevronSize)
    targetLeftChecvronNode.name = AppConstants.ComponentNames.targetLeftChevronName
    targetLeftChecvronNode.lineWidth = 2.5
    targetLeftChecvronNode.strokeColor = .gray
    targetLeftChecvronNode.position = CGPoint(x: 0.0, y: 0.0)
    targetLeftChecvronNode.zPosition = -1
    targetLeftChecvronNode.zRotation = -1.0
    self.node.addChild(targetLeftChecvronNode)
    
    let targetRightChecvronNode = SKShapeNode(rectOf: chevronSize)
    targetRightChecvronNode.name = AppConstants.ComponentNames.targetRightChevronName
    targetRightChecvronNode.lineWidth = 2.5
    targetRightChecvronNode.strokeColor = .gray
    targetRightChecvronNode.position = CGPoint(x: 0.0, y: 0.0)
    targetRightChecvronNode.zPosition = -1
    targetRightChecvronNode.zRotation = 1.0
    self.node.addChild(targetRightChecvronNode)
    
    let roationCircleNode = SKSpriteNode(imageNamed: "launch-rotation-1")
    roationCircleNode.name = AppConstants.ComponentNames.rotationCircleName
    roationCircleNode.zPosition = -2
    self.node.addChild(roationCircleNode)
    
    let magnitudePilarNode = SKSpriteNode(imageNamed: "launch-magnitude-1")
    magnitudePilarNode.name = AppConstants.ComponentNames.magnitudePilarName
    magnitudePilarNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
    magnitudePilarNode.zPosition = -3
    self.node.addChild(magnitudePilarNode)
    
    super.init()
    
    self.hide()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(touchPosition: CGPoint) {
    guard let hero = self.entity as? General,
      let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
      let targetPosition = self.launchInfo.lastTouchBegan else { return }
    
    let heroPosition = heroSpriteComponent.node.position
    let heroRotation = heroSpriteComponent.node.zRotation
    
    let isFarNegitiveVector = self.getIsNegitiveLaunchVector(p1: heroPosition,
                                                             p2: targetPosition,
                                                             touchPosition: touchPosition,
                                                             linePosition: heroPosition)
    guard !isFarNegitiveVector else {
      self.hide()
      return
    }
    
    let intersect = self.getIntersect(heroPosition: heroPosition,
                                      targetPosition: targetPosition,
                                      touchPosition: touchPosition)
    
    let launchVector = heroPosition.vectorTo(point: targetPosition)
    
    let midSwipeDistPos = self.getSwipeDistPos(vector: launchVector,
                                               targetPosition: targetPosition,
                                               percent: 0.5)
    
    let swipeIntersectVector = intersect.vectorTo(point: midSwipeDistPos)
    
    let heroLaunchRotation = launchVector.rotation - heroRotation
    let isLeftRotation = self.getIsLeftRotation(heroPosition: heroPosition,
                                                targetPosition: targetPosition,
                                                touchPosition: touchPosition)
    
    let rotationVector = touchPosition.vectorTo(point: intersect)
    
    let isNegitiveVector = self.getIsNegitiveLaunchVector(p1: heroPosition,
                                                          p2: midSwipeDistPos,
                                                          touchPosition: touchPosition,
                                                          linePosition: midSwipeDistPos)
    // Caculate launch distance
    let swipeMagnitude = min(AppConstants.Touch.maxSwipeDistance, swipeIntersectVector.length())
    let launchMagnitude = isNegitiveVector ? 0.0 : swipeMagnitude
    let launchPercent = launchMagnitude / 100
    
    // Caculate launch rotation
    let rotationMagnitude = min(AppConstants.Touch.maxRotation, rotationVector.length())
    let rotationStepPercent = MagnitudeLevel.rotationStep(magnitude: rotationMagnitude)
    
    self.updateCompontUI(launchVector: launchVector,
                         launchRotation: heroLaunchRotation,
                         launchMagnitude: launchMagnitude,
                         launchPercent: launchPercent,
                         rotaitonMagnitude: rotationMagnitude,
                         rotationStepPercent: rotationStepPercent,
                         isLeftRotation: isLeftRotation)
    
    self.launchInfo.direction = launchVector
    self.launchInfo.directionPercent = launchPercent
    self.launchInfo.rotationPercent = rotationStepPercent
    self.launchInfo.isLeftRotation = isLeftRotation
  }
  
  private func updateCompontUI(launchVector: CGVector,
                               launchRotation: CGFloat,
                               launchMagnitude: CGFloat,
                               launchPercent: CGFloat,
                               rotaitonMagnitude: CGFloat,
                               rotationStepPercent: CGFloat,
                               isLeftRotation: Bool) {
    let magnitudePilarNode = self.node.childNode(withName: AppConstants.ComponentNames.magnitudePilarName) as? SKSpriteNode
    let rotationCircleNode = self.node.childNode(
      withName: AppConstants.ComponentNames.rotationCircleName) as? SKSpriteNode
    let targetLineNode = self.node.childNode(
      withName: AppConstants.ComponentNames.targetLineName) as? SKShapeNode
    let baseLineNode = self.node.childNode(
      withName: AppConstants.ComponentNames.targetBaseLineName) as? SKShapeNode
    let midCircleNode = self.node.childNode(
      withName: AppConstants.ComponentNames.targetMidCircleName) as? SKShapeNode
    let chevronLeftNode = self.node.childNode(
      withName: AppConstants.ComponentNames.targetLeftChevronName) as? SKShapeNode
    let chevronRightNode = self.node.childNode(
      withName: AppConstants.ComponentNames.targetRightChevronName) as? SKShapeNode
    let launchLineNode = self.node.childNode(withName: AppConstants.ComponentNames.launchLineName)
    let halfSwipeDistance = AppConstants.Touch.maxSwipeDistance / 2
    
    launchLineNode?.alpha = 0.0
    
    // Rotate the parent node
    self.node.zRotation = launchRotation
    
    // Pilar image
    let magnitudeImage = MagnitudeLevel.imageNameFor(fileName: "launch-magnitude",
                                                     percent: launchMagnitude)
    magnitudePilarNode?.setTexture(imageNamed: magnitudeImage)
    magnitudePilarNode?.alpha = 1.0
//    magnitudePilarNode.alpha = directionPercent
    
    // Target line
    targetLineNode?.alpha = LaunchComponent.targetLineAlpha
        
    // Circle image
    let rotationImage = MagnitudeLevel.imageNameFor(fileName: "launch-rotation",
                                                    percent: rotaitonMagnitude)
    rotationCircleNode?.setTexture(imageNamed: rotationImage)
    rotationCircleNode?.alpha = 1.0
//    rotationCircleNode?.alpha = rotationPercent
    rotationCircleNode?.xScale = isLeftRotation ? 1.0 : -1.0
    
    // Base line position
    baseLineNode?.position = CGPoint(x: 0.0, y: launchVector.length() - halfSwipeDistance)
    baseLineNode?.alpha = LaunchComponent.targetLineAlpha
    
    // Mid circle position
    midCircleNode?.position = CGPoint(x: 0.0, y: launchVector.length())
    midCircleNode?.alpha = LaunchComponent.targetLineAlpha
    
    let posX = Self.targetNodeWidth * 0.3
    let posY = launchVector.length() + halfSwipeDistance - Self.targetNodeWidth * 0.3

    // target left chevron position
    chevronLeftNode?.position = CGPoint(x: posX, y: posY)
    chevronLeftNode?.alpha = LaunchComponent.targetLineAlpha
    
    // target right chevron position
    chevronRightNode?.position = CGPoint(x: -posX, y: posY)
    chevronRightNode?.alpha = LaunchComponent.targetLineAlpha
  }
  
  func hide() {
    self.node.childNode(withName: AppConstants.ComponentNames.targetLineName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.rotationCircleName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.targetBaseLineName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.targetMidCircleName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.targetLeftChevronName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.targetRightChevronName)?.alpha = 0.0
    self.node.childNode(withName: AppConstants.ComponentNames.magnitudePilarName)?.alpha = 0.0
    self.launchInfo.clear()
  }
}

extension LaunchComponent {
  private func getMagnitude(length: CGFloat) {
    
  }
  
  private func getSwipeDistPos(vector: CGVector,
                               targetPosition: CGPoint,
                               percent: CGFloat) -> CGPoint {
    let halfMaxSwipeDist = AppConstants.Touch.maxSwipeDistance * percent
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
  
  // This function computes the rotation direction by checking if the point is
  // below or above the target line accordingly
  private func getIsLeftRotation(heroPosition: CGPoint,
                                 targetPosition: CGPoint,
                                 touchPosition: CGPoint) -> Bool {
    var isLeft = false
    if heroPosition.x == targetPosition.x {
      // horizontal target slope
      if heroPosition.y < targetPosition.y {
        isLeft = touchPosition.x < targetPosition.x
      } else if heroPosition.y > targetPosition.y {
        isLeft = touchPosition.x > targetPosition.x
      }
       
    } else if heroPosition.y == targetPosition.y {
      // horizontal target slope
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
  
  // This function checks if the point is below or above the perpendicular line
  private func getIsNegitiveLaunchVector(p1: CGPoint,
                                         p2: CGPoint,
                                         touchPosition: CGPoint,
                                         linePosition: CGPoint) -> Bool {
    var isNegitive = false
    if p1.x == p2.x {
      // horizontal target slope
      if p1.y < p2.y {
        isNegitive = touchPosition.y < p2.y
      } else if p1.y > p2.y {
        isNegitive = touchPosition.y > p2.y
      }
    } else if p1.x == p2.x {
      // horizontal target slope
      if p1.x < p2.x {
        isNegitive = touchPosition.x < p2.x
      } else if p1.x > p2.x {
        isNegitive = touchPosition.x > p2.x
      }
    } else {
      let touchSlope = p1.slopeTo(point: p2)
      let perpendicularSlope = -1 / touchSlope
      
      if p1.y > p2.y {
        isNegitive = touchPosition.isAbove(point: linePosition, slope: perpendicularSlope)
      } else if p1.y < p2.y {
        isNegitive = !touchPosition.isAbove(point: linePosition, slope: perpendicularSlope)
      }
    }

    return isNegitive
  }
}

extension LaunchComponent {
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
}

extension LaunchComponent {
  enum MagnitudeLevel {
    case percent0
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
    
    var magnitudePecent: CGFloat {
      switch self {
      case .percent0: return 0.0
      case .percent10: return 0.1
      case .percent20: return 0.2
      case .percent30: return 0.3
      case .percent40: return 0.4
      case .percent50: return 0.5
      case .percent60: return 0.6
      case .percent70: return 0.7
      case .percent80: return 0.8
      case .percent90: return 0.9
      case .percent100: return 1.0
      }
    }
  }
}

extension LaunchComponent.MagnitudeLevel {
  static func rotationStep(magnitude: CGFloat) -> CGFloat {
    let rotationPercent = magnitude / 100
    let magnitudeLevel = Self.magnitudeStep(percent: rotationPercent)
    
    return magnitudeLevel.magnitudePecent
  }
  
  static func magnitudeStep(percent: CGFloat) -> LaunchComponent.MagnitudeLevel {
    switch percent {
    case 0...0.1: return .percent0
    case 0.1...0.2: return .percent20
    case 0.2...0.3: return .percent30
    case 0.3...0.4: return .percent40
    case 0.4...0.5: return .percent50
    case 0.5...0.6: return .percent60
    case 0.6...0.7: return .percent70
    case 0.7...0.8: return .percent80
    case 0.8...0.9: return .percent90
    case 0.9...1.0: return .percent100
    case let p where p < 0: return .percent10
    case let p where p > 100: return .percent100
    default: return .percent0
    }
  }
  
  static func imageNameFor(fileName: String, percent: CGFloat) -> String {
    switch percent {
    case 0...10: return "\(fileName)-0"
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
