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
  
  private let defaultImpulseMagnitude: CGFloat = 2.0
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
      guard self.state == .moving else { return }
      guard let physicsComponent = self.component(ofType: PhysicsComponent.self) else { return }
    
      physicsComponent.isEffectedByPhysics = true
    }
  }
  var numberOfDeposits: Int {
    guard let deliveredComponent = self.component(ofType: DeliveredComponent.self) else { return 0 }
    
    return deliveredComponent.resources.count
  }
  
  unowned var occupiedPanel: Panel? = nil

  init(imageName: String, team: Team, resourceReleased: @escaping (SKShapeNode) -> Void) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: imageName))
    spriteComponent.node.zPosition = SpriteZPosition.hero.rawValue
    self.addComponent(spriteComponent)
    self.addComponent(TeamComponent(team: team))
    
    let physicsBody = self.getPhysicsBody()
    self.addComponent(PhysicsComponent(physicsBody: physicsBody))    
    spriteComponent.node.physicsBody = physicsBody

    self.addComponent(ImpulseComponent())
    
    self.addComponent(HandsComponent(didRemoveResource: { resource in
      guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
      
      resourceReleased(shapeComponent.node)
    }))
    
    let trailComponent = TrailComponent()
    self.addComponent(trailComponent)
    if let emitter = trailComponent.emitter {
//      spriteComponent.node.addChild(emitter)
    }
    
    let nameComponent = AliasComponent()
    self.addComponent(nameComponent)
//    spriteComponent.node.addChild(nameComponent.node)
    
    let launchComponent = LaunchComponent()
    spriteComponent.node.addChild(launchComponent.node)
    self.addComponent(launchComponent)
    
    self.addComponent(DeliveredComponent())
    
    self.setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func switchToState(_ state: State) {
      switch (state) {
      case .idle:
        self.stopAllAnimation()
        self.startAnimation(type: .idle)
        
        self.state = .idle
      case .moving:
        self.stopAllAnimation()
        self.startAnimation(type: .moving)
        
        self.state = .moving
      case .beamed:
        self.isBeamable = false
        
        self.stopAllAnimation()
        self.startAnimation(type: .idle)
        
        if let launchComponent = self.component(ofType: LaunchComponent.self) {
          let launchLineNode = launchComponent.node.childNode(withName: AppConstants.ComponentNames.launchLineName) as? SKShapeNode
          launchLineNode?.alpha = LaunchComponent.targetLineAlpha
        }
        
        self.state = .beamed
      }
    
      self.updateResourcePositions()
    }
  
  private func getPhysicsBody() -> SKPhysicsBody {
    // TODO: Send and handle a state parameter here
    let physicsBody = SKPhysicsBody(circleOfRadius: 10)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    physicsBody.collisionBitMask = PhysicsCategoryMask.package | PhysicsCategoryMask.hero
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
  var isBeamable: Bool = true
  
  func resetBeamTimer() {
    DispatchQueue.main.asyncAfter(deadline: .now() + General.beamResetTime) {
      [weak self] in
      
      guard let self = self else { return }
      
      self.isBeamable = true
    }
  }
  
}

extension General {
  enum AnimationType: String, CaseIterable {
    case idle
    case moving
    case diving
  }
  
  func startAnimation(type: AnimationType) {
    guard let spriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    if spriteComponent.node.action(forKey: type.rawValue) == nil {
      let action: SKAction
      switch type {
      case .idle:
        action = self.idleAction
      case .moving: action = self.moveAction
      default: action = self.moveAction
      }
      
      spriteComponent.node.run( SKAction.repeatForever(action), withKey: type.rawValue)
    }
  }
  
  func stopAnimation(type: AnimationType) {
    guard let spriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAction(forKey: type.rawValue)
  }
  
  func stopAllAnimation() {
    for type in General.AnimationType.allCases {
      self.stopAnimation(type: type)
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
    self.idleAction = SKAction.animate(with: idleTextures, timePerFrame: 0.2)
    
    var moveTextures:[SKTexture] = []
    for i in 0..<5 {
      moveTextures.append(SKTexture(imageNamed: "spaceman-move-\(i)"))
    }
    for i in (0..<5).reversed() {
      moveTextures.append(SKTexture(imageNamed: "spaceman-move-\(i)"))
    }
    self.moveAction = SKAction.animate(with: moveTextures, timePerFrame: 0.1)
  }
  
  func updateResourcePositions() {
    guard let handsComponent = self.component(ofType: HandsComponent.self) else { return }
    
    let leftPos: CGPoint
    let rightPos: CGPoint
    switch self.state {
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
    guard let heroHandsComponent = self.component(ofType: HandsComponent.self) else { return }
    
    heroHandsComponent.isImpacted = true
    
    if let resource = heroHandsComponent.leftHandSlot {
      heroHandsComponent.release(resource: resource, point: point)
    }
    
    if let resource = heroHandsComponent.rightHandSlot {
      heroHandsComponent.release(resource: resource, point: point)
    }
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
  
  func impulseTo(location: CGPoint, completion: (SKSpriteNode, CGVector, CGFloat) -> Void) {
    guard let spriteComponent = self.component(ofType: SpriteComponent.self),
      let impulseComponent = self.component(ofType: ImpulseComponent.self),
      let physicsComponent = self.component(ofType: PhysicsComponent.self) else { return }
    
    guard !impulseComponent.isOnCooldown else { return }
    
    impulseComponent.isOnCooldown = true
    self.switchToState(.moving)
    
    let moveVector = CGVector(dx: location.x - spriteComponent.node.position.x,
                             dy: location.y - spriteComponent.node.position.y)
    self.impulse(vector: moveVector.normalized() * self.defaultImpulseMagnitude)
  
    completion(spriteComponent.node,
               physicsComponent.physicsBody.velocity,
               physicsComponent.physicsBody.angularVelocity)
  }
}

extension General: LaunchableProtocol {
  func updateLaunchComponents(touchPosition: CGPoint) {
    guard let launchComponent = self.component(ofType: LaunchComponent.self),
      let physicsComponent = self.component(ofType: PhysicsComponent.self),
      (self.isBeamed && !physicsComponent.isEffectedByPhysics) else { return }
  
    launchComponent.update(touchPosition: touchPosition)
  }
  
  func launch(completion: LaunchAftermath? = nil) {
    guard let spriteComponent = self.component(ofType: SpriteComponent.self),
      let physicsComponent = self.component(ofType: PhysicsComponent.self),
      let launchComponent = self.component(ofType: LaunchComponent.self),
      let moveVector = launchComponent.launchInfo.direction,
      let movePercent = launchComponent.launchInfo.directionPercent,
      let rotationPercent = launchComponent.launchInfo.rotationPercent,
      let isLeftRotation = launchComponent.launchInfo.isLeftRotation,
      let beamComponent = self.occupiedPanel?.component(ofType: BeamComponent.self),
      let occupiedPanel = self.occupiedPanel else { return }
    
    self.switchToState(.moving)
    beamComponent.isOccupied = false
      
    let launchMagnitude = self.defaultImpulseMagnitude * 2
    let impulseVector = moveVector.normalized() * launchMagnitude * movePercent
    let angularVelocity = self.defaultLaunchRotation * rotationPercent
    self.impulse(vector: impulseVector,
                 angularVelocity: isLeftRotation ? -1 * angularVelocity : angularVelocity)
    
    launchComponent.hide()
    
    self.resetBeamTimer()
    completion?(spriteComponent.node,
                physicsComponent.physicsBody.velocity,
                physicsComponent.physicsBody.angularVelocity,
                occupiedPanel)
  }
}

extension General: ThrowableProtocol {
  func throwResourceAt(point: CGPoint) {
    guard let handsComponent = self.component(ofType: HandsComponent.self),
      let spriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    let throwVector = spriteComponent.node.position.vectorTo(point: point)
    
    if let rightResource = handsComponent.rightHandSlot {
      handsComponent.isImpacted = true
      handsComponent.release(resource: rightResource, point: point)
      
      if let physicsComponent = self.component(ofType: PhysicsComponent.self),
        let resourcePhysicsComponent = rightResource.component(ofType: PhysicsComponent.self) {
        
        
        resourcePhysicsComponent.physicsBody.velocity = .zero
        
        resourcePhysicsComponent.physicsBody.velocity = physicsComponent.physicsBody.velocity
        resourcePhysicsComponent.physicsBody.applyImpulse(throwVector * defaultThrowMagnitude)
        
        rightResource.wasThrown = true
      }
    } else if let leftResource = handsComponent.leftHandSlot {
        handsComponent.isImpacted = true
        handsComponent.release(resource: leftResource, point: point)
        
        if let physicsComponent = self.component(ofType: PhysicsComponent.self),
          let resourcePhysicsComponent = leftResource.component(ofType: PhysicsComponent.self) {
          
          resourcePhysicsComponent.physicsBody.velocity = .zero
          
          resourcePhysicsComponent.physicsBody.velocity = physicsComponent.physicsBody.velocity
          resourcePhysicsComponent.physicsBody.applyImpulse(throwVector)
        }
      
        leftResource.wasThrown = true
      }
    }
}
