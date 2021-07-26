//
//  Panel.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/7/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class Panel: GKEntity {
  
  enum BeamArrangment: Int {
    case top
    case bottom
    case both
    case none
  }
  
  var beamColor = UIColor.magenta
  
  init(shapeNode: SKShapeNode,
       physicsBody: SKPhysicsBody,
       team: Team? = nil,
       config: BeamArrangment = .both) {
    super.init()
    
    self.addComponent(ShapeComponent(node: shapeNode))
    self.addComponent(PhysicsComponent(physicsBody: physicsBody))
    
    shapeNode.physicsBody = physicsBody
    
    let size = shapeNode.frame.size
    let tractorSize = CGSize(width: size.width * 0.4, height: size.width * 0.05)
    let beamPhysicsBody = SKPhysicsBody(rectangleOf: tractorSize)
    beamPhysicsBody.isDynamic = false
    beamPhysicsBody.categoryBitMask = PhysicsCategoryMask.tractor
    beamPhysicsBody.contactTestBitMask = PhysicsCategoryMask.hero
    
    if let team = team {
      shapeNode.strokeColor = team.color
      shapeNode.fillColor = team.offColor
      let teamComponent = TeamComponent(team: team)
      self.addComponent(teamComponent)
    }
    
    var tractorBeams = [SKShapeNode]()
    if config == BeamArrangment.top || config == BeamArrangment.both {
      let topBeam = SKShapeNode(rectOf: tractorSize, cornerRadius: size.width * 0.01)
      topBeam.lineWidth = 2.5
      topBeam.strokeColor = self.beamColor
      topBeam.position = CGPoint(x: 0.0, y: size.width/4)
      topBeam.physicsBody = beamPhysicsBody.copy() as? SKPhysicsBody
      
      shapeNode.addChild(topBeam)
      tractorBeams.append(topBeam)
    }
  
    if config == BeamArrangment.bottom || config == BeamArrangment.both {
      let tractorBeam = SKShapeNode(rectOf: tractorSize, cornerRadius: size.width * 0.01)
      tractorBeam.lineWidth = 2.5
      tractorBeam.strokeColor = self.beamColor
      tractorBeam.position = CGPoint(x: 0.0, y: -size.width/4)
      tractorBeam.physicsBody = beamPhysicsBody.copy() as? SKPhysicsBody
      tractorBeam.zRotation = CGFloat.pi

      shapeNode.addChild(tractorBeam)
      tractorBeams.append(tractorBeam)
    }
    
    self.addComponent(BeamComponent(nodes: tractorBeams))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
