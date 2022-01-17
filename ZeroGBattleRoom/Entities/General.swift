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


class General: GKEntity, BeamableProtocol {
  
  private let defaultImpulseMagnitude: CGFloat = 1.0
  private let defaultLaunchRotation: CGFloat = 10.0
  private let defaultThrowMagnitude: CGFloat = 5.0
  
  private var idleAction: SKAction!
  private var moveAction: SKAction!
  private var diveAction: SKAction!
  
  enum State {
    case idle
    case moving
    case beamed
  }
  
  private(set) var state: State = .idle {
    didSet {
      guard state == .moving else { return }
      guard let physicsComponent = component(ofType: PhysicsComponent.self) else { return }
    
      physicsComponent.isEffectedByPhysics = true
    }
  }
  
  var numberOfDeposits: Int {
    guard let deliveredComponent = delivered else { return 0 }
    
    return deliveredComponent.resources.count
  }

  init(imageName: String, team: Team) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: imageName))
    spriteComponent.node.zPosition = SpriteZPosition.hero.rawValue
    addComponent(spriteComponent)
    addComponent(TeamComponent(team: team))
    
    let physicsBody = getPhysicsBody()
    addComponent(PhysicsComponent(physicsBody: physicsBody))
    spriteComponent.node.physicsBody = physicsBody

    addComponent(ImpulseComponent())
    addComponent(HandsComponent())
    
    let trailComponent = TrailComponent()
    addComponent(trailComponent)
//    if let emitter = trailComponent.emitter {
//      spriteComponent.node.addChild(emitter)
//    }
    
    addComponent(AliasComponent())
    
    let launchComponent = LaunchComponent()
    spriteComponent.node.addChild(launchComponent.node)
    addComponent(launchComponent)
    
    addComponent(DeliveredComponent())
    
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func switchToState(_ state: State) {
      switch (state) {
      case .idle:
        stopAllAnimation()
        startAnimation(type: .idle)
        
        self.state = .idle
      case .moving:
        stopAllAnimation()
        startAnimation(type: .moving)
        
        self.state = .moving
      case .beamed:
        isBeamable = false
        
        stopAllAnimation()
        startAnimation(type: .idle)
        
        self.state = .beamed
      }
    
      updateResourcePositions()
    }
  
  func getPhysicsBody() -> SKPhysicsBody {
    // TODO: Send and handle a state parameter here
    let physicsBody = SKPhysicsBody(circleOfRadius: 10)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    physicsBody.collisionBitMask = PhysicsCategoryMask.package | PhysicsCategoryMask.hero | PhysicsCategoryMask.wall | PhysicsCategoryMask.field
    physicsBody.contactTestBitMask = PhysicsCategoryMask.hero
    
    return physicsBody
  }
  
  // MARK: - Conform to BeamableProtocol
  
  static let beamResetTime: Double = 0.5
  
  unowned var occupiedPanel: Panel? = nil
  
  var isBeamed: Bool {
    return state == .beamed
  }
  var isBeamable: Bool = true
  
}

extension General {
  
  enum AnimationType: String, CaseIterable {
    case idle
    case moving
    case diving
  }
  
  func startAnimation(type: AnimationType) {
    guard let spriteComponent = component(ofType: SpriteComponent.self) else { return }
    
    if spriteComponent.node.action(forKey: type.rawValue) == nil {
      let action: SKAction
      switch type {
      case .idle:
        action = idleAction
      case .moving: action = moveAction
      default: action = moveAction
      }
      
      spriteComponent.node.run( SKAction.repeatForever(action), withKey: type.rawValue)
    }
  }
  
  func stopAnimation(type: AnimationType) {
    guard let spriteComponent = component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAction(forKey: type.rawValue)
  }
  
  func stopAllAnimation() {
    for type in General.AnimationType.allCases {
      stopAnimation(type: type)
    }
  }
  
  private func setupActions() {
    var idleTextures:[SKTexture] = []
    for i in 0..<4 {
      idleTextures.append(SKTexture(imageNamed: "spaceman-idle-\(i)"))
    }
    for i in (0..<4).reversed() {
      idleTextures.append(SKTexture(imageNamed: "spaceman-idle-\(i)"))
    }
    idleAction = SKAction.animate(with: idleTextures, timePerFrame: 0.2)
    
    var moveTextures:[SKTexture] = []
    for i in 0..<5 {
      moveTextures.append(SKTexture(imageNamed: "spaceman-move-\(i)"))
    }
    for i in (0..<5).reversed() {
      moveTextures.append(SKTexture(imageNamed: "spaceman-move-\(i)"))
    }
    moveAction = SKAction.animate(with: moveTextures, timePerFrame: 0.1)
  }
  
  func updateResourcePositions() {
    guard let handsComponent = component(ofType: HandsComponent.self) else { return }
    
    let leftPos: CGPoint
    let rightPos: CGPoint
    switch state {
    case .idle:
      leftPos = CGPoint(x: -9, y: 15)
      rightPos = CGPoint(x: 9, y: 15)
    case .moving:
      leftPos = CGPoint(x: -9, y: 22)
      rightPos = CGPoint(x: 9, y: 22)
    case .beamed:
      leftPos = CGPoint(x: -9, y: 15)
      rightPos = CGPoint(x: 9, y: 15)
    }
    
    if let slot = handsComponent.leftHandSlot,
      let shapeComponent = slot.component(ofType: ShapeComponent.self) {
      
      shapeComponent.node.position = leftPos
    }
    
    if let slot = handsComponent.rightHandSlot,
      let shapeComponent = slot.component(ofType: ShapeComponent.self) {
    
      shapeComponent.node.position = rightPos
    }
  }
  
}

extension General: ImpactableProtocol {
  
  func impactedAt(point: CGPoint) {
    guard let heroHandsComponent = component(ofType: HandsComponent.self) else { return }
    
    heroHandsComponent.isImpacted = true
    
    if let resource = heroHandsComponent.leftHandSlot,
       let resourceTrail = resource.component(ofType: TrailComponent.self) {
      heroHandsComponent.release(resource: resource, point: point)
      resourceTrail.type = .resource
    }
    
    if let resource = heroHandsComponent.rightHandSlot,
       let resourceTrail = resource.component(ofType: TrailComponent.self) {
      heroHandsComponent.release(resource: resource, point: point)
      resourceTrail.type = .resource
    }
  }
  
}

extension General: ImpulsableProtocol {
  
  func impulse(vector: CGVector, angularVelocity: CGFloat = 0.0) {
    if let physicsComponent = component(ofType: PhysicsComponent.self),
      let spriteComponent = component(ofType: SpriteComponent.self) {

      physicsComponent.physicsBody.applyImpulse(vector)
      physicsComponent.physicsBody.angularVelocity = angularVelocity
      spriteComponent.node.zRotation = vector.rotation
    }
  }
  
  func impulseTo(location: CGPoint, completion: (SKSpriteNode, CGVector, CGFloat) -> Void) {
    guard let spriteComponent = component(ofType: SpriteComponent.self),
      let impulseComponent = component(ofType: ImpulseComponent.self),
      let physicsComponent = component(ofType: PhysicsComponent.self) else { return }
    
    guard !impulseComponent.isOnCooldown else { return }
    
    impulseComponent.isOnCooldown = true
    switchToState(.moving)
    
    let moveVector = CGVector(dx: location.x - spriteComponent.node.position.x,
                             dy: location.y - spriteComponent.node.position.y)
    impulse(vector: moveVector.normalized() * defaultImpulseMagnitude)
  
    completion(spriteComponent.node,
               physicsComponent.physicsBody.velocity,
               physicsComponent.physicsBody.angularVelocity)
  }
  
}

extension General: LaunchableProtocol {
  
  func updateLaunchComponents(touchPosition: CGPoint) {
    guard let launchComponent = component(ofType: LaunchComponent.self),
      let physicsComponent = component(ofType: PhysicsComponent.self),
      (isBeamed && !physicsComponent.isEffectedByPhysics) else { return }
  
    launchComponent.update(touchPosition: touchPosition)
  }
  
  func launch(completion: LaunchAftermath? = nil) {
    guard let spriteComponent = component(ofType: SpriteComponent.self),
      let physicsComponent = component(ofType: PhysicsComponent.self),
      let launchComponent = component(ofType: LaunchComponent.self),
      let moveVector = launchComponent.launchInfo.direction,
      let movePercent = launchComponent.launchInfo.directionPercent,
      let rotationPercent = launchComponent.launchInfo.rotationPercent,
      let isLeftRotation = launchComponent.launchInfo.isLeftRotation,
      let beamComponent = occupiedPanel?.component(ofType: BeamComponent.self),
      let occupiedPanel = occupiedPanel else { return }
    
    switchToState(.moving)
    beamComponent.isOccupied = false
      
    let launchMagnitude = defaultImpulseMagnitude * 2
    let impulseVector = moveVector.normalized() * launchMagnitude * movePercent
    let angularVelocity = defaultLaunchRotation * rotationPercent
    impulse(vector: impulseVector,
                 angularVelocity: isLeftRotation ? -1 * angularVelocity : angularVelocity)
    
    launchComponent.hide()
    
    completion?(spriteComponent.node,
                physicsComponent.physicsBody.velocity,
                physicsComponent.physicsBody.angularVelocity,
                occupiedPanel)
  }
  
}

extension General: ThrowableProtocol {
  
  func throwResourceAt(point: CGPoint) {
    guard let handsComponent = component(ofType: HandsComponent.self),
      let spriteComponent = component(ofType: SpriteComponent.self) else { return }
    
    let throwVector = spriteComponent.node.position.vectorTo(point: point)
    
    if let rightResource = handsComponent.rightHandSlot {
      handsComponent.isImpacted = true
      handsComponent.release(resource: rightResource, point: point)
      
      if let physicsComponent = component(ofType: PhysicsComponent.self),
         let resourcePhysicsComponent = rightResource.component(ofType: PhysicsComponent.self) {
        
        resourcePhysicsComponent.physicsBody.velocity = .zero
        resourcePhysicsComponent.physicsBody.velocity = physicsComponent.physicsBody.velocity
        resourcePhysicsComponent.physicsBody.applyImpulse(throwVector * defaultThrowMagnitude)
      }
      
      rightResource.wasThrownBy = self
    } else if let leftResource = handsComponent.leftHandSlot {
      handsComponent.isImpacted = true
      handsComponent.release(resource: leftResource, point: point)
      
      if let physicsComponent = component(ofType: PhysicsComponent.self),
         let resourcePhysicsComponent = leftResource.component(ofType: PhysicsComponent.self) {
        
        resourcePhysicsComponent.physicsBody.velocity = .zero
        resourcePhysicsComponent.physicsBody.velocity = physicsComponent.physicsBody.velocity
        resourcePhysicsComponent.physicsBody.applyImpulse(throwVector * defaultThrowMagnitude )
      }
      
      leftResource.wasThrownBy = self
    }
  }
  
}
