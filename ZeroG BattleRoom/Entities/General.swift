//
//  General.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


protocol GeneralImpulsableProtocol {
  func impulse(vector: CGVector)
}

protocol GeneralImpactableProtocol {
  func impacted()
}


class General: GKEntity {

  init(imageName: String, team: Team, addShape: @escaping (SKShapeNode) -> Void) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: imageName))
    spriteComponent.node.name = AppConstants.ComponentNames.heroPlayerName
    spriteComponent.node.zPosition = 10
    self.addComponent(spriteComponent)
    self.addComponent(TeamComponent(team: team))
    
    let physicsBody = self.getPhysicsBody()
    self.addComponent(PhysicsComponent(physicsBody: physicsBody))    
    spriteComponent.node.physicsBody = physicsBody

    self.addComponent(ImpulseComponent())
    
    self.addComponent(ResourceComponent(didSetResource: { shapeNode in
      spriteComponent.node.addChild(shapeNode)
    }, didRemoveResourece: { shapeNode in
      addShape(shapeNode)
    }))
    
    let trailComponent = TrailComponent()
    if let emitter = trailComponent.emitter {
      self.addComponent(trailComponent)
      
      spriteComponent.node.addChild(emitter)
    }
    
    let nameComponent = AliasComponent()
    self.addComponent(nameComponent)
    spriteComponent.node.addChild(nameComponent.node)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func getPhysicsBody() -> SKPhysicsBody {
    let spriteComponent = self.component(ofType: SpriteComponent.self)!
    
    let physicsBody = SKPhysicsBody(circleOfRadius: spriteComponent.node.size.height / 2)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    physicsBody.collisionBitMask = PhysicsCategoryMask.package
    
    return physicsBody
  }
  
}

extension General: GeneralImpulsableProtocol {
  func impulse(vector: CGVector) {
    if let physicsComponent = self.component(ofType: PhysicsComponent.self),
      let spriteComponent = self.component(ofType: SpriteComponent.self),
      let impulseComponent = self.component(ofType: ImpulseComponent.self) {
      
      guard !impulseComponent.isOnCooldown else { return }
      
      physicsComponent.physicsBody.applyImpulse(vector.normalized())
      physicsComponent.physicsBody.angularVelocity = 0.0
      spriteComponent.node.zRotation = atan2(vector.dy, vector.dx) - CGFloat.pi / 2
    }
  }
}

extension General: GeneralImpactableProtocol {
  func impacted() {
    guard let heroResourceComponent = self.component(ofType: ResourceComponent.self),
      let heroSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    if let heroResource = heroResourceComponent.resource,
      let shapeComponent = heroResource.component(ofType: ShapeComponent.self) {
      
      heroResourceComponent.isImpacted = true
      heroResourceComponent.resource = nil
      shapeComponent.node.position = heroSpriteComponent.node.position
      heroResource.enableCollisionDetections()
    }
  }
}
