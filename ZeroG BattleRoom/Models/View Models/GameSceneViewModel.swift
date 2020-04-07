//
//  GameSceneViewModel.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/24/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


public class GameSceneViewModel {
  enum WallOrientation {
    case vertical
    case horizontal
    case fallingDiag
    case risingDiag
  }
  
  var currentPlayerIndex = 0
  var resourcesDelivered = 0
  
  var resourceNode: SKShapeNode?
  var spinnyNode : SKShapeNode?
  var wallNode: Wall?
  
  var gameMessage: SKLabelNode?
  var subTitleMessage: SKLabelNode?
  
  var borderBody: SKPhysicsBody
  
  var wallNodeCopy: Wall? {
    return self.wallNode?.copy() as? Wall
  }

  var spinnyNodeCopy: SKShapeNode? {
    return self.spinnyNode?.copy() as? SKShapeNode
  }
  
  init(frame: CGRect) {
    let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
    borderBody.friction = 0
    self.borderBody = borderBody
    
    self.createShapeNodeForResource()
    self.createShapeNodeForWall()
    self.createSpinnyNode()
    
    self.createResourceNodes()
      
//    let captain = Captain()
//    captain.switchToState(.idle)
  }
  
  func getWallSegment(number: Int, orientation: WallOrientation = .horizontal) -> [Wall] {
    var segments = [Wall]()
  
    var position = orientation.startingPosition(numberOfWalls: number)
    for _ in 0..<number {
      defer { position = orientation.nextPosition(position: position)}

      if let wall = self.wallNode?.copy() as? Wall {
        wall.position = position
        wall.zRotation = orientation.rotation
        segments.append(wall)
      }
    }
    return segments
  }
}

extension GameSceneViewModel {
  private func createResourceNodes() {
//    for _ in 0..<numberOfSpawnedResources {
////      guard let resourceNode = self.resourceNode?.copy() as! SKShapeNode? else { return }
////
////      resourceNode.strokeColor = SKColor.green
////
////      self.resources.append(resourceNode)
//      let width: CGFloat = 10.0
//      let size = CGSize(width: width, height: width)
//     let resourceNode = SKShapeNode(rectOf: size, cornerRadius: width * 0.3)
//      resourceNode.lineWidth = 2.5
//            
//      let radius = resourceNode.frame.size.height / 2.0
//      let physicsBody = SKPhysicsBody(circleOfRadius: radius)
//      physicsBody.friction = 0.0
//      physicsBody.restitution = 1.0
//      physicsBody.linearDamping = 0.0
//      physicsBody.angularDamping = 0.0
//      physicsBody.categoryBitMask = PhysicsCategoryMask.package
//      physicsBody.contactTestBitMask = PhysicsCategoryMask.hero
//      physicsBody.collisionBitMask = PhysicsCategoryMask.hero
//      resourceNode.physicsBody = physicsBody
//      
//      resourceNode.strokeColor = SKColor.green
//      self.resources.append(resourceNode)
//    }
  }
  
  private func createShapeNodeForResource() {
    let width: CGFloat = 10.0
    let size = CGSize(width: width, height: width)
    
    self.resourceNode = SKShapeNode(rectOf: size,cornerRadius: width * 0.3)
    
    guard let resourceNode = self.resourceNode else { return }
    
    resourceNode.lineWidth = 2.5
          
    let radius = resourceNode.frame.size.height / 2.0
    let physicsBody = SKPhysicsBody(circleOfRadius: radius)
    physicsBody.friction = 0.0
    physicsBody.restitution = 1.0
    physicsBody.linearDamping = 0.0
    physicsBody.angularDamping = 0.0
    physicsBody.categoryBitMask = PhysicsCategoryMask.package
    physicsBody.contactTestBitMask = PhysicsCategoryMask.hero
    physicsBody.collisionBitMask = PhysicsCategoryMask.hero
    resourceNode.physicsBody = physicsBody
  }
  
  private func createShapeNodeForWall() {
    self.wallNode = Wall(rectOf: AppConstants.Layout.wallSize,
                         cornerRadius: AppConstants.Layout.wallCornerRadius)
    
    guard let wallNode = self.wallNode else { return }
    
    wallNode.setup()
  }
  
  private func createSpinnyNode() {
    let frame = UIScreen.main.bounds
    let width = (frame.size.width + frame.size.height) * 0.05
    self.spinnyNode = SKShapeNode(rectOf: CGSize(width: width, height: width),
                                  cornerRadius: width * 0.3)
    
    
    guard let spinnyNode = self.spinnyNode else { return }
    
    spinnyNode.lineWidth = 2.5
    
    spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
    spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                      SKAction.fadeOut(withDuration: 0.5),
                                      SKAction.removeFromParent()]))
  }
}

extension GameSceneViewModel.WallOrientation {
  var rotation: CGFloat {
    var rotation: CGFloat = 0.0
    if case .vertical = self {
      rotation = CGFloat.pi / 2
    }
    
    return rotation
  }
  
  func startingPosition(numberOfWalls: Int) -> CGPoint {
    let wallLength = AppConstants.Layout.wallSize.width
    let wallThickness = AppConstants.Layout.wallSize.height
    let wallWidth = wallLength * CGFloat(numberOfWalls)
    
    var startingPoint = CGPoint.zero
    if case .horizontal = self {
      startingPoint.x = -wallWidth / 2 + wallLength / 2
      startingPoint.y = 0.0
    }
    
    if case .vertical = self {
      startingPoint.x = 0.0
      startingPoint.y = -wallWidth / 2 + wallLength / 2
    }
    
    if case .fallingDiag = self {
      startingPoint.x = -wallWidth / 2 + wallThickness / 2
      startingPoint.y = wallWidth / 2 + wallLength / 2
    }
    
    if case .risingDiag = self {
      startingPoint.x = -wallWidth / 2 + wallThickness / 2
      startingPoint.y = -wallWidth / 2 + wallLength / 2
    }
    
    return startingPoint
  }
  
  func nextPosition(position: CGPoint) -> CGPoint {
    let wallLength = AppConstants.Layout.wallSize.width
    
    var nextPoint = position
    if case .horizontal = self {
      nextPoint.x = position.x + wallLength
      nextPoint.y = position.y
    }
    
    if case .vertical = self {
      nextPoint.x = position.x
      nextPoint.y = position.y + wallLength
    }
    
    if case .fallingDiag = self {
      nextPoint.x = position.x - wallLength
      nextPoint.y = position.y - wallLength
    }
    
    if case .risingDiag = self {
      nextPoint.x = position.x + wallLength
      nextPoint.y = position.y + wallLength
    }
    
    return nextPoint
  }
}
