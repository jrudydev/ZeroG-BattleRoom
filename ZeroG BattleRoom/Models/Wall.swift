//
//  Wall.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/25/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

class Wall: SKShapeNode {
  enum BeamConfig: Int {
    case topBeamOnly
    case bottomBeamOnly
    case bothBeams
  }
  
  var topBeam: SKShapeNode? = nil
  var bottomBeam: SKShapeNode? = nil
  
  private let beamColor = UIColor.magenta
  
  func setup () {
    self.name = "wall"
    self.lineWidth = 2.5
    self.fillColor = UIColor.gray
    self.strokeColor = UIColor.white
    
    let size = self.frame.size
    let physicsBody = SKPhysicsBody(rectangleOf: size)
//    physicsBody.affectedByGravity = false
    physicsBody.isDynamic = false
    
    self.physicsBody = physicsBody
    
    let tractorSize = CGSize(width: size.width * 0.4, height: size.width * 0.05)
    let beamPhysicsBody = SKPhysicsBody(rectangleOf: tractorSize)
    beamPhysicsBody.isDynamic = false
    beamPhysicsBody.categoryBitMask = PhysicsCategoryMask.wall
    beamPhysicsBody.contactTestBitMask = PhysicsCategoryMask.hero
    beamPhysicsBody.collisionBitMask = PhysicsCategoryMask.hero
    
    self.topBeam = SKShapeNode(rectOf: tractorSize, cornerRadius: size.width * 0.01)
    self.topBeam!.lineWidth = 2.5
    self.topBeam!.strokeColor = self.beamColor
    self.topBeam!.physicsBody = beamPhysicsBody
    self.topBeam!.position = CGPoint(x: 0.0, y: size.width/4)
    
    self.addChild(self.topBeam!)
    
    self.bottomBeam = SKShapeNode(rectOf: tractorSize, cornerRadius: size.width * 0.01)
    self.bottomBeam!.lineWidth = 2.5
    self.bottomBeam!.strokeColor = self.beamColor
    self.bottomBeam!.physicsBody = beamPhysicsBody
    self.bottomBeam!.position = CGPoint(x: 0.0, y: -size.width/4)
    self.bottomBeam!.zRotation = CGFloat.pi
    
    self.addChild(self.bottomBeam!)
  }
  
  func config(_ config: BeamConfig) {
    if case .topBeamOnly = config {
      self.bottomBeam?.removeFromParent()
      self.bottomBeam = nil
    }
    
    if case .bottomBeamOnly = config {
      self.topBeam?.removeFromParent()
      self.topBeam = nil
    }
  }
}
