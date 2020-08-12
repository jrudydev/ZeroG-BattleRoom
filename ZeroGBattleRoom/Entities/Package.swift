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
    
    self.addComponent(ShapeComponent(node: shapeNode))
    self.addComponent(PhysicsComponent(physicsBody: self.physicsBody))
    
    shapeNode.physicsBody = self.physicsBody
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
    
    physicsComponent.physicsBody = self.physicsBody
    shapeComponent.node.physicsBody = self.physicsBody
  }
}

extension Package {
  func placeFor(tutorialStep: Tutorial.Step) {
    if let shapeComponent = self.component(ofType: ShapeComponent.self),
      let physicsComponent = self.component(ofType: PhysicsComponent.self) {
      
      DispatchQueue.main.async {
        shapeComponent.node.position = tutorialStep.midPosition
        physicsComponent.physicsBody.velocity = .zero
      }
    }
  }
}
