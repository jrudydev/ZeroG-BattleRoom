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



class General: GKEntity {
  
  private let defaultImpulseMagnitude: CGFloat = 3.0
  private let defaultLaunchRotation: CGFloat = 10.0
  
  enum State {
    case idle
    case moving
    case beamed
  }
  
  var state: State = .idle {
    didSet {
      guard self.state == .moving else { return }
      guard let physicsComponent = self.component(ofType: PhysicsComponent.self) else { return }
    
      physicsComponent.isEffectedByPhysics = true
    }
  }
  var numberOfDeposits = 0
  
  unowned var tractorBeamComponent: TracktorBeamComponent? = nil

  init(imageName: String, team: Team, resourceReleased: @escaping (SKShapeNode) -> Void) {
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
    
    self.addComponent(HandsComponent(didRemoveResource: { resource in
      guard let heroSpriteComponent = self.component(ofType: SpriteComponent.self),
        let shapeComponent = resource.component(ofType: ShapeComponent.self),
        let physicsComponent = resource.component(ofType: PhysicsComponent.self) else { return }
      
      DispatchQueue.main.async {
        shapeComponent.node.position = heroSpriteComponent.node.position
        physicsComponent.randomImpulse()
      }
      
      resourceReleased(shapeComponent.node)
    }))
    
    let trailComponent = TrailComponent()
    self.addComponent(trailComponent)
    if let emitter = trailComponent.emitter {
      spriteComponent.node.addChild(emitter)
    }
    
    let nameComponent = AliasComponent()
    self.addComponent(nameComponent)
    spriteComponent.node.addChild(nameComponent.node)
    
    let launchComponent = LaunchComponent()
    spriteComponent.node.addChild(launchComponent.node)
    self.addComponent(launchComponent)
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
    physicsBody.collisionBitMask = PhysicsCategoryMask.hero
    physicsBody.contactTestBitMask = PhysicsCategoryMask.hero
    
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
    DispatchQueue.main.asyncAfter(deadline: .now() + General.beamResetTime) {
      [weak self] in
      
      guard let self = self else { return }
      
      self.switchToState(.moving)
    }
  }
  
}

extension General: ImpactableProtocol {
  func impacted() {
    guard let heroHandsComponent = self.component(ofType: HandsComponent.self) else { return }
    
    heroHandsComponent.isImpacted = true
    heroHandsComponent.leftHandSlot = nil
    heroHandsComponent.rightHandSlot = nil
  }
}

extension General: ImpulsableProtocol {
  func impulse(vector: CGVector, angularVelocity: CGFloat = 0.0) {
    if let physicsComponent = self.component(ofType: PhysicsComponent.self),
      let spriteComponent = self.component(ofType: SpriteComponent.self) {
  
      physicsComponent.physicsBody.applyImpulse(vector)
      physicsComponent.physicsBody.angularVelocity = angularVelocity
      spriteComponent.node.zRotation = vector.rotation
    }
  }
  
  func impulseTo(location: CGPoint, completion: (SKSpriteNode, CGVector) -> Void) {
    guard let spriteComponent = self.component(ofType: SpriteComponent.self),
      let impulseComponent = self.component(ofType: ImpulseComponent.self) else { return }
    
    guard !impulseComponent.isOnCooldown else { return }
    
    let moveVector = CGVector(dx: location.x - spriteComponent.node.position.x,
                             dy: location.y - spriteComponent.node.position.y)
    
    self.impulse(vector: moveVector.normalized() * self.defaultImpulseMagnitude)
    impulseComponent.isOnCooldown = true
    
    completion(spriteComponent.node, moveVector)
  }
}

extension General: LaunchableProtocol {
  func launch() {
    guard let physicsComponent = self.component(ofType: PhysicsComponent.self),
      let launchComponent = self.component(ofType: LaunchComponent.self),
      let moveVector = launchComponent.launchInfo.direction,
      let movePercent = launchComponent.launchInfo.directionPercent,
      let rotationPercent = launchComponent.launchInfo.rotationPercent,
      let isLeftRotation = launchComponent.launchInfo.isLeftRotation else { return }
    
    if let tractorBeamComponent = self.tractorBeamComponent {
      physicsComponent.isEffectedByPhysics = true
      tractorBeamComponent.isOccupied = false
    }
    
    let launchMagnitude = self.defaultImpulseMagnitude * 2
    let impulseVector = moveVector.normalized() * launchMagnitude * movePercent
    let angularVelocity = self.defaultLaunchRotation * rotationPercent
    self.impulse(vector: impulseVector,
                 angularVelocity: isLeftRotation ? -1 * angularVelocity : angularVelocity)
    
    launchComponent.hide()
    self.resetBeamTimer()
  }
}
