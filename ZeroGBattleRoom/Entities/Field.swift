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
import AVFAudio


protocol Entity {
  func setupComponents()
  func setupPhysics()
}

class Field: GKEntity {
  
  private var entityModel: FieldEntityModel
  
  var isEngaged: Bool { entityModel.isEngaged }

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

class FieldEntityModel {
  
  enum Constants {
    
    static let fieldRadius: CGFloat = 50.0
    static let fieldAlpha: CGFloat = 0.3
    static let shutterAnimationDelay: CGFloat = 4.0
  
  }
  
  let shapeNode: SKShapeNode
  let physicsBody: SKPhysicsBody
  var isEngaged: Bool = true {
    didSet {
      if isEngaged {
        disengage()
        isEngaged = false
      } else {
        engage()
        isEngaged = true
      }
    }
  }
  
  private var shutterAnimation: SKAction? = nil
  
  init(node: SKShapeNode = FieldEntityModel.defaultShapeNode, physics: SKPhysicsBody = FieldEntityModel.defaultPhysicsBody) {
    self.shapeNode = node
    self.physicsBody = physics
    
    setupShutterAnimation()
    startShutter()
  }
  
  private func setupShutterAnimation() {
    let loop = SKAction.repeatForever(SKAction.sequence([
      SKAction.run({ [weak self] in self?.isEngaged = true }),
      SKAction.wait(forDuration: Constants.shutterAnimationDelay),
      SKAction.run({ [weak self] in self?.isEngaged = false }),
      SKAction.wait(forDuration: Constants.shutterAnimationDelay)
    ]))
    shutterAnimation = SKAction.sequence([SKAction.wait(forDuration: 1.0), loop])
  }
  
  static private var defaultPhysicsBody: SKPhysicsBody {
    let physicsBody = SKPhysicsBody(circleOfRadius: Constants.fieldRadius)
    physicsBody.isDynamic = false
    physicsBody.categoryBitMask = PhysicsCategoryMask.field
    return physicsBody
  }
  
  static private var defaultShapeNode: SKShapeNode {
    let node = SKShapeNode(circleOfRadius: Constants.fieldRadius)
    node.fillColor = .blue
    node.strokeColor = .white
    node.alpha = Constants.fieldAlpha
    
    return node
  }
  
}

extension FieldEntityModel {
  
  func engage() {
    shapeNode.alpha = Constants.fieldAlpha
  }
  
  func disengage() {
    shapeNode.alpha = 0.0
  }
  
  func startShutter() {
    guard let animation = shutterAnimation else { return }
    shapeNode.run(animation)
  }
  
  func endShutter() {
    shapeNode.removeAllActions()
  }
  
}
