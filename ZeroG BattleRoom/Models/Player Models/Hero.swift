//
//  Hero.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/24/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import Combine

protocol HeroProtocol: ImpactableProtocol, BeamableProtocol, CollectorProtocol {}
protocol CaptainProtocol: ImpulsableProtocol {}


class CaptainNode: SKNode, CaptainProtocol {
  
  enum State {
    case idle
    case moving
    case beamed
  }
  
  private var state: State = .idle
  var playerCooldownNode: SKShapeNode!
  var collectedResources = 0
  
  
  // MARK: - ImpulsableProtocol Delegate Methods
  
  var impulseCooldown: Double = 1.0
  var isImpulseOnCooldown = false {
    didSet {
      guard self.isImpulseOnCooldown == true else { return }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + self.impulseCooldown) {
        [weak self] in
        
        guard let self = self else { return }
        
        self.isImpulseOnCooldown = false
      }
    }
  }
  
  func impulse(vector: CGVector) {
    if self.physicsBody?.isDynamic == false {
      self.physicsBody?.isDynamic = true
//      self.resetBeamTimer()
    }
    
    self.physicsBody?.velocity = CGVector.zero
    self.physicsBody?.applyImpulse(vector.normalized())
    self.zRotation = atan2(vector.dy, vector.dx) - CGFloat.pi / 2
  }
}



class Hero: SKSpriteNode, HeroProtocol {

  enum State {
    case idle
    case moving
    case beamed
  }
  
  private var state: State = .idle
  
  var playerAliasLabel: SKLabelNode!
  
  // MARK: - Conform to CollectorProtocol

  var resourceNode: SKShapeNode? = nil {
    willSet {
      guard let resourceNode = self.resourceNode else { return }
      
      resourceNode.removeFromParent()
    }
    didSet {
      guard let resourceNode = self.resourceNode else { return }
      
      if let _ = resourceNode.parent {
        resourceNode.removeFromParent()
      }
      
      self.addChild(resourceNode)
    }
  }
  
  var collectedResources = 0
  
  
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
  
  
  // MARK: - Conform to ImpactableProtocol
  
  var isImpacted = false {
    didSet {
      guard self.isImpacted == true else { return }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        guard let self = self else { return }
        
        self.isImpacted = false
      }
    }
  }
  
  
  // MARK: - Conform to ImpulsableProtocol
  
  var impulseCooldown: Double = 1.0
  var isImpulseOnCooldown = false {
    didSet {
      guard self.isImpulseOnCooldown == true else { return }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + self.impulseCooldown) {
        [weak self] in
        
        guard let self = self else { return }
        
        self.isImpulseOnCooldown = false
      }
    }
  }
  
  func impulse(vector: CGVector) {
    if self.physicsBody?.isDynamic == false {
      self.physicsBody?.isDynamic = true
      self.resetBeamTimer()
    }
    
    self.physicsBody?.velocity = CGVector.zero
    self.physicsBody?.applyImpulse(vector.normalized())
    self.zRotation = atan2(vector.dy, vector.dx) - CGFloat.pi / 2
  }
  
}

extension Hero {
  func setupPhysicsBody() {
    let physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    self.physicsBody = physicsBody
  }
  
  func setupTrail(node: SKNode) {
    if let trail = SKEmitterNode(fileNamed: "BallTrail") {
      trail.targetNode = node
      self.addChild(trail)
    }
  }
  
  func setupAliasLabel() {
    self.playerAliasLabel = SKLabelNode(fontNamed: "Arial")
    self.playerAliasLabel.fontSize = 20
    self.playerAliasLabel.fontColor = SKColor.red
    self.playerAliasLabel.position = CGPoint(x: 0.0, y: 40.0)
    self.playerAliasLabel.name = AppConstants.ComponentNames.gameMessageName
    self.addChild(self.playerAliasLabel)
  }
  
  func setPlayerAliasText(playerAlias: String) {
//    let playerAliasLabel = self.childNode(withName: AppConstants.ComponentNames.gameMessageName)
    self.playerAliasLabel?.text = playerAlias
  }
  
  func switchToState(_ state: State) {
    switch (state) {
    case .idle:
      self.physicsBody?.velocity = CGVector.zero
    case .moving:
      self.state = .moving
    case .beamed:
      self.state = .beamed
    }
  }
}
