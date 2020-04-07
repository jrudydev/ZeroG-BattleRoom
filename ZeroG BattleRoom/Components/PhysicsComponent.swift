//
//  PhysicsComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


struct PhysicsCategoryMask {
  static var hero     : UInt32 = 0x1 << 0
  static var base     : UInt32 = 0x1 << 1
  static var wall     : UInt32 = 0x1 << 2
  static var strap    : UInt32 = 0x1 << 3
  static var payload  : UInt32 = 0x1 << 4
  static var package  : UInt32 = 0x1 << 5
  static var deposit  : UInt32 = 0x1 << 6
  static var pod      : UInt32 = 0x1 << 7
}


class PhysicsComponent: GKComponent {
  
  var physicsBody: SKPhysicsBody
  
  var isEffectedByPhysics = true {
    didSet {
      if self.isEffectedByPhysics {
        physicsBody.isDynamic = true
      } else {
        physicsBody.isDynamic = false
        physicsBody.velocity = CGVector.zero
        physicsBody.angularVelocity = 0.0
      }
    }
  }
  
  init(physicsBody: SKPhysicsBody) {
    self.physicsBody = physicsBody
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension PhysicsComponent {
  func randomImpulse() {
    let randomX = (Bool.random() ? -1 : 1) * (Double.random(in: 1...2))
    let randomY = (Bool.random() ? -1 : 1) * (Double.random(in: 1...2))
    self.physicsBody.applyImpulse(CGVector(dx: randomX, dy: randomY))
  }
}
