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
  
  static let maxSpeed: CGFloat = 400.0
  
  let physicsBody: SKPhysicsBody
  
  weak var wasThrownBy: General? = nil
  
  init(shapeNode: SKShapeNode, physicsBody: SKPhysicsBody) {
    self.physicsBody = physicsBody
    
    super.init()
    
    addComponent(ShapeComponent(node: shapeNode))
    addComponent(PhysicsComponent(physicsBody: self.physicsBody))
    
    let trailComponent = TrailComponent()
    addComponent(trailComponent)
    if let emitter = trailComponent.emitter {
      shapeNode.addChild(emitter)
    }
    
    shapeNode.physicsBody = self.physicsBody
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

extension Package {
  
  func disableCollisionDetection() {
    guard let shapeComponent = component(ofType: ShapeComponent.self) else { return }

    shapeComponent.node.physicsBody = nil
  }
  
  func enableCollisionDetections() {
    guard let shapeComponent = component(ofType: ShapeComponent.self),
      let physicsComponent = component(ofType: PhysicsComponent.self) else { return }
    
    physicsComponent.physicsBody = physicsBody
    shapeComponent.node.physicsBody = physicsBody
  }
  
}

extension Package {
  
  func placeFor(tutorialStep: Tutorial.Step) {
    if let shapeComponent = component(ofType: ShapeComponent.self),
      let physicsComponent = component(ofType: PhysicsComponent.self) {
      
      DispatchQueue.main.async {
        shapeComponent.node.position = tutorialStep.midPosition
        physicsComponent.physicsBody.velocity = .zero
      }
    }
  }
  
}

extension Package {
  
  func deposit(_ delivered: DeliveredComponent) {
    guard let resourceShape = component(ofType: ShapeComponent.self) else { return }
    
    resourceShape.node.removeFromParent()
    delivered.resources.insert(self)
  }
  
}
