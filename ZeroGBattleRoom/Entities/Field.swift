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
  
  internal var entityModel: FieldEntityModel

  init(entityModel: FieldEntityModel) {
    self.entityModel = entityModel
    
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
    addComponent(ShapeComponent(node: entityModel.shapeNode))
    addComponent(PhysicsComponent(physicsBody: entityModel.physicsBody))
  }
  
  func setupPhysics() {
    entityModel.shapeNode.physicsBody = entityModel.physicsBody
  }

}

struct FieldEntityModel {
  
  let shapeNode: SKShapeNode
  let physicsBody: SKPhysicsBody
  
}
