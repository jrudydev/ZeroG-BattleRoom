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

      guard let heroNode = firstBody.node as? SKSpriteNode,
        let resourceNode = secondBody.node as? SKShapeNode else { return }
      
      guard let hero = self.entityManager.heroWith(node: heroNode) as? General,
        let impactedResource = self.entityManager.resourceWith(node: resourceNode) as? Package else { return }
      
      guard let heroHandsComponent = hero.component(ofType: HandsComponent.self),
        let impactedResourceComponent = impactedResource.component(ofType: ShapeComponent.self),
        !heroHandsComponent.isImpacted else { return }
      
      if let heroLeftHand = heroHandsComponent.leftHandSlot,
        let heroRightHand = heroHandsComponent.rightHandSlot,
        let leftHandPhysicsComponent = heroLeftHand.component(ofType: PhysicsComponent.self),
        let rightHandPhysicsComponent = heroRightHand.component(ofType: PhysicsComponent.self) {
      
        hero.impacted()
        
        if self.viewModel.currentPlayerIndex == 0 {
          leftHandPhysicsComponent.randomImpulse()
          rightHandPhysicsComponent.randomImpulse()
        }
      } else {
        impactedResource.disableCollisionDetection()
//        impactedResourceComponent.node.zPosition = 100
        if heroHandsComponent.leftHandSlot == nil {
          heroHandsComponent.leftHandSlot = impactedResource
        } else {
          heroHandsComponent.rightHandSlot = impactedResource
        }
      }
      
      self.run(SoundManager.shared.blipPaddleSound)
      print("collition occured")
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero && secondBody.categoryBitMask == PhysicsCategoryMask.deposit {
      
      guard let heroNode = firstBody.node as? SKSpriteNode,
        let depositNode = secondBody.node as? SKShapeNode else { return }
      
      guard let hero = self.entityManager.heroWith(node: heroNode) as? General,
        let deposit = self.entityManager.enitityWith(node: depositNode) as? Deposit else { return }
      
      guard let handsComponent = hero.component(ofType: HandsComponent.self),
        let teamComponent = hero.component(ofType: TeamComponent.self),
        let depositShapeComponent = deposit.component(ofType: ShapeComponent.self),
        let depositComponent = deposit.component(ofType: DepositComponent.self),
        (handsComponent.leftHandSlot != nil || handsComponent.rightHandSlot != nil) else { return }
        
      var total = 0
      if let lefthanditem = handsComponent.leftHandSlot {
        handsComponent.leftHandSlot = nil
        
        if let shapeComponent = lefthanditem.component(ofType: ShapeComponent.self) {
          shapeComponent.node.removeFromParent()
        }
        
        total += 1
      }
      
      if let rightHandItem = handsComponent.rightHandSlot {
        handsComponent.rightHandSlot = nil
        
        if let shapeComponent = rightHandItem.component(ofType: ShapeComponent.self) {
          shapeComponent.node.removeFromParent()
        }
        
        total += 1
      }
      
      self.viewModel.resourcesDelivered += total
      hero.numberOfDeposits += total
      
      switch teamComponent.team {
      case .team1: depositComponent.team1Deposits += total
      case .team2: depositComponent.team2Deposits += total
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
    
      self.run(SoundManager.shared.bambooBreakSound)
      print("deposit occured")
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero && secondBody.categoryBitMask == PhysicsCategoryMask.wall {
      
      guard let heroNode = firstBody.node as? SKSpriteNode,
        let beam = secondBody.node as? SKShapeNode else { return }
      
      guard let hero = self.entityManager.heroWith(node: heroNode) as? General,
        let spriteComponent = hero.component(ofType: SpriteComponent.self),
        let physicsComponent = hero.component(ofType: PhysicsComponent.self),
        let panel = self.entityManager.panelWith(node: beam) as? Panel,
        let panelShapeComponent = panel.component(ofType: ShapeComponent.self),
        !hero.isBeamed else { return }

      physicsComponent.isEffectedByPhysics = false
      
      let isTopBeam = beam.position.y == abs(beam.position.y)
      let convertedPosition = beam.scene?.convert(beam.position, from: panelShapeComponent.node)
      let rotation = isTopBeam ? beam.zRotation : panelShapeComponent.node.zRotation + CGFloat.pi
      
      DispatchQueue.main.async {
        spriteComponent.node.position = convertedPosition ?? panelShapeComponent.node.position
        spriteComponent.node.zRotation = rotation
      }
      
      hero.switchToState(.beamed)
      
      self.run(SoundManager.shared.blipSound)
      print("wall hit")
    }
  }
}
