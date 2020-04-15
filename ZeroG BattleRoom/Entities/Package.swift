//
//  Package.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class Package: GKEntity {
  
  init(shapeNode: SKShapeNode) {
    super.init()
    
    self.addComponent(ShapeComponent(node: shapeNode))
    let physicsBody = self.getPhysicsBody()
    self.addComponent(PhysicsComponent(physicsBody: physicsBody))
    
    shapeNode.physicsBody = physicsBody
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func getPhysicsBody() -> SKPhysicsBody {
    let shapeComponent = self.component(ofType: ShapeComponent.self)!
    let radius = shapeComponent.node.frame.size.height / 2.0
    
    let physicsBody = SKPhysicsBody(circleOfRadius: radius)
    physicsBody.friction = 0.0
    physicsBody.restitution = 1.0
    physicsBody.linearDamping = 0.0
    physicsBody.angularDamping = 0.0
    physicsBody.categoryBitMask = PhysicsCategoryMask.package
    physicsBody.contactTestBitMask = PhysicsCategoryMask.hero
    physicsBody.collisionBitMask = PhysicsCategoryMask.hero
    
    return physicsBody
  }

}

extension Package {
  
  func disableCollisionDetection() {
    guard let shapeComponent = self.component(ofType: ShapeComponent.self) else { return }

    shapeComponent.node.physicsBody = nil
  }
  
  func enableCollisionDetections() {
    guard let shapeComponent = self.component(ofType: ShapeComponent.self),
      let physicsComponent = self.component(ofType: PhysicsComponent.self) else { return }

    let physicsBody = self.getPhysicsBody()
    physicsComponent.physicsBody = physicsBody
    shapeComponent.node.physicsBody = physicsBody
  }
  
}
