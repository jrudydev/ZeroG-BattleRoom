//
//  Captain.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/24/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

class Captain: BasePlayer, ImpulsableProtocol, BeamableProtocol {
  enum State {
    case idle
    case moving
    case beamed
    case shooting
  }
  
  private var state: State = .idle
  
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
  

  // MARK: - Conform to ImpulsableProtocol
  
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
  
  var impulseCooldown: Double = 5.0
  
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
