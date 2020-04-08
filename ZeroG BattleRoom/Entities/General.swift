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
  
  enum State {
    case idle
    case moving
    case beamed
  }
  
  private var state: State = .idle
  
  var numberOfDeposits = 0

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
    
    self.addComponent(HandsComponent(didSetResource: { shapeNode in
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
  
  func switchToState(_ state: State) {
      switch (state) {
      case .idle: break
  //      self.physicsBody?.velocity = CGVector.zero
      case .moving:
        self.state = .moving
      case .beamed:
        self.state = .beamed
      }
    }
  
  private func getPhysicsBody() -> SKPhysicsBody {
    let spriteComponent = self.component(ofType: SpriteComponent.self)!
    
    let physicsBody = SKPhysicsBody(circleOfRadius: spriteComponent.node.size.height / 2)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    physicsBody.collisionBitMask = PhysicsCategoryMask.package
    
    return physicsBody
  }
  
  // MARK: - Conform to BeamableProtocol
  
  static let beamResetTime: Double = 0.5
  
  unowned var beam: SKShapeNode? = nil
  
  var isBeamed: Bool {
    get {
      return self.state == .beamed
    }
  }
  
  func resetBeamTimer() {
    DispatchQueue.main.asyncAfter(deadline: .now() + Hero.beamResetTime) {
      [weak self] in
      
      guard let self = self else { return }
      
      self.switchToState(.moving)
    }
  }
  
}

extension General: GeneralImpulsableProtocol {
  func impulse(vector: CGVector) {
    if let physicsComponent = self.component(ofType: PhysicsComponent.self),
      let spriteComponent = self.component(ofType: SpriteComponent.self),
      let impulseComponent = self.component(ofType: ImpulseComponent.self) {
      
      guard !impulseComponent.isOnCooldown else { return }
      
      // TODO: Remove this once impulse timer is implemented
      if physicsComponent.physicsBody.isDynamic == false {
        physicsComponent.isEffectedByPhysics = true
        self.resetBeamTimer()
      }
      
      physicsComponent.physicsBody.applyImpulse(vector.normalized())
      physicsComponent.physicsBody.angularVelocity = 0.0
      spriteComponent.node.zRotation = atan2(vector.dy, vector.dx) - CGFloat.pi / 2
    }
  }
}

extension General: GeneralImpactableProtocol {
  func impacted() {
    guard let heroHandsComponent = self.component(ofType: HandsComponent.self),
      let heroSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    if let heroResource = heroHandsComponent.leftHandSlot,
      let shapeComponent = heroResource.component(ofType: ShapeComponent.self) {
      
      heroHandsComponent.isImpacted = true
      heroHandsComponent.leftHandSlot = nil
      heroHandsComponent.rightHandSlot = nil
      shapeComponent.node.position = heroSpriteComponent.node.position
      heroResource.enableCollisionDetections()
    }
  }
}

