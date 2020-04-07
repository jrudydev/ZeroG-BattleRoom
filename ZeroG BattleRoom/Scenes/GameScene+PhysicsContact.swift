//
//  GameScene+PhysicsContact.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    guard self.gameState.currentState is Playing  else { return }
    
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero &&
      secondBody.categoryBitMask == PhysicsCategoryMask.package {
      
//      guard let hero = self.entityManager.hero as? General else { return }
//      guard let spriteComponent = hero.component(ofType: SpriteComponent.self),
//        let impulseComponent = hero.component(ofType: ImpulseComponent.self) else { return }
      
      guard let heroNode = firstBody.node as? SKSpriteNode,
        let resourceNode = secondBody.node as? SKShapeNode else { return }
      
      guard let hero = self.entityManager.heroWith(node: heroNode) as? General,
        let impactedResource = self.entityManager.resourceWith(node: resourceNode) as? Package else { return }
      
      guard let heroResourceComponent = hero.component(ofType: ResourceComponent.self),
        let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
        let impactedResourceComponent = impactedResource.component(ofType: ShapeComponent.self),
        !heroResourceComponent.isImpacted else { return }
      
      if let heroResource = heroResourceComponent.resource,
        let shapeComponent = heroResource.component(ofType: ShapeComponent.self),
        let physicsComponent = heroResource.component(ofType: PhysicsComponent.self),
        !heroResourceComponent.isImpacted {
      
        hero.impacted()
        
        if self.viewModel.currentPlayerIndex == 0 {
          physicsComponent.randomImpulse()
        }
      } else {
        impactedResource.disableCollisionDetection()
        impactedResourceComponent.node.zPosition = 100
        heroResourceComponent.resource = impactedResource
      }
      
      self.run(SoundManager.shared.blipPaddleSound)
      print("collition occured")
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero && secondBody.categoryBitMask == PhysicsCategoryMask.deposit {
      
      guard let heroNode = firstBody.node as? SKSpriteNode,
        let depositNode = secondBody.node as? SKShapeNode else { return }
      
      guard let hero = self.entityManager.heroWith(node: heroNode) as? General,
        let deposit = self.entityManager.enitityWith(node: depositNode) as? Deposit else { return }
      
      guard let spriteComponent = hero.component(ofType: SpriteComponent.self),
        let resourceComponent = hero.component(ofType: ResourceComponent.self),
        let teamComponent = hero.component(ofType: TeamComponent.self),
        let depositShapeComponent = deposit.component(ofType: ShapeComponent.self),
        let depositComponent = deposit.component(ofType: DepositComponent.self),
        resourceComponent.resource != nil else { return }
        
      self.viewModel.resourcesDelivered += 1
      
      switch teamComponent.team {
      case .team1: depositComponent.team1Deposits += 1
      case .team2: depositComponent.team2Deposits += 1
      }
      
      if let label = self.gameMessage {
        label.text = "Deposit"
        label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
      }
      
      if let particles = SKEmitterNode(fileNamed: "Block") {
        particles.position = depositShapeComponent.node.position
        particles.zPosition = 3
        self.addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
      }
    
      let resource = resourceComponent.resource
      resourceComponent.resource = nil
      
      if let shapeComponent = resource?.component(ofType: ShapeComponent.self) {
        shapeComponent.node.removeFromParent()
      }
      
      self.run(SoundManager.shared.bambooBreakSound)
      print("deposit occured")
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero && secondBody.categoryBitMask == PhysicsCategoryMask.wall {
      
      if let heroNode = firstBody.node as? SKSpriteNode,
        let hero = self.entityManager.heroWith(node: heroNode) as? General {
        hero.impacted()
      }
      
      guard let hero = firstBody.node as? Hero,
        let beam = secondBody.node as? SKShapeNode,
        let wall = beam.parent,
        !hero.isBeamed else { return }
      
      hero.physicsBody?.isDynamic = false
      hero.physicsBody?.velocity = CGVector.zero
      hero.physicsBody?.angularVelocity = 0.0
      
      DispatchQueue.main.async {
        let isTopBeam = beam.position.y == abs(beam.position.y)
        hero.zRotation = isTopBeam ? wall.zRotation : wall.zRotation + CGFloat.pi
        let convertedPosition = beam.scene?.convert(beam.position, from: wall)
        hero.position = convertedPosition ?? wall.position
      }
      
      hero.switchToState(.beamed)
      
      self.run(SoundManager.shared.blipSound)
      print("wall hit")
    }
  }
}
