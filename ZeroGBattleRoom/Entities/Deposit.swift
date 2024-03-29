//
//  Deposit.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class Deposit: GKEntity {
  
  static let eventHorizon: CGFloat = 20.0
  static let pullDistance: CGFloat = 100.0
  
  override init() {
    super.init()
    
    let shapeNode = SKShapeNode(circleOfRadius: Deposit.eventHorizon)
    shapeNode.name = AppConstants.ComponentNames.depositNodeName
    shapeNode.fillColor = .black
    addComponent(ShapeComponent(node: shapeNode))
    let physicsBody = getPhysicsBody()
    addComponent(PhysicsComponent(physicsBody: physicsBody))
    
    shapeNode.physicsBody = physicsBody

    addComponent(DepositComponent())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func getPhysicsBody() -> SKPhysicsBody {
    let physicsBody = SKPhysicsBody(circleOfRadius: Deposit.eventHorizon)
   
    physicsBody.categoryBitMask = PhysicsCategoryMask.deposit
    physicsBody.contactTestBitMask = PhysicsCategoryMask.hero | PhysicsCategoryMask.package
    physicsBody.collisionBitMask = 0
    
    return physicsBody
  }
}
