//
//  FieldEntity.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/14/21.
//  Copyright © 2021 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

protocol Entity {
  func setupComponents()
  func setupPhysics()
}

class Field: GKEntity {
  
  private let shapeNode: SKShapeNode
  private let physicsBody: SKPhysicsBody

  init(shapeNode: SKShapeNode,
       physicsBody: SKPhysicsBody) {
    self.shapeNode = shapeNode
    self.physicsBody = physicsBody
    
    super.init()
    
    setupComponents()
    setupPhysics()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension Field: Entity {
  
  func setupComponents() {
    addComponent(ShapeComponent(node: shapeNode))
    addComponent(PhysicsComponent(physicsBody: physicsBody))
  }
  
  func setupPhysics() {
    shapeNode.physicsBody = physicsBody
  }

}
