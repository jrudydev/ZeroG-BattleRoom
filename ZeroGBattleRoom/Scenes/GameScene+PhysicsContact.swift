//
//  GameScene+PhysicsContact.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

extension GameScene: SKPhysicsContactDelegate {
  
  func didEnd(_ contact: SKPhysicsContact) {
    guard gameState.currentState is Playing ||
      gameState.currentState is Tutorial else { return }
    
    let (firstBody, secondBody) = contact.physicsBodies
  
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero &&
      secondBody.categoryBitMask == PhysicsCategoryMask.tractor {
      
      guard let heroNode = firstBody.node as? SKSpriteNode else { return }
      
      guard let hero = entityManager.heroWith(node: heroNode) as? General else { return }
      
      hero.isBeamable = true
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    guard gameState.currentState is Playing ||
      gameState.currentState is Tutorial else { return }
    
    let (firstBody, secondBody) = contact.physicsBodies
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero &&
      secondBody.categoryBitMask == PhysicsCategoryMask.hero {
      
      handleHeroHeroCollision(firstBody: firstBody, secondBody: secondBody)
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero &&
      secondBody.categoryBitMask == PhysicsCategoryMask.package {

      handleHeroPackageCollision(firstBody: firstBody, secondBody: secondBody)
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero &&
      secondBody.categoryBitMask == PhysicsCategoryMask.deposit {
      
      handleHeroDepositCollision(firstBody: firstBody, secondBody: secondBody)
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.hero &&
      secondBody.categoryBitMask == PhysicsCategoryMask.tractor {
      
      handleHeroWallCollision(firstBody: firstBody, secondBody: secondBody)
    }
    
    if firstBody.categoryBitMask == PhysicsCategoryMask.wall &&
      secondBody.categoryBitMask == PhysicsCategoryMask.package {
        
      guard let resourceNode = secondBody.node as? SKShapeNode,
        let impactedResource = entityManager.resourceWith(node: resourceNode) as? Package else { return }
      
      impactedResource.wasThrownBy = nil
    }
  }
  
  public func handleDeposit(package: Package) {
    guard package.wasThrownBy != nil else { return }
    guard gameState.currentState is Tutorial else {
      // TODO: - Handle in-game thrown deposit
      return
    }
    guard let currentStep = tutorialAction?.currentStep else { return }
    guard package.wasThrownBy === entityManager.hero else {
      setupHintAnimations(step: currentStep)
      return
    }
    guard tutorialAction?.setupNextStep() == nil else { return }
  
    gameOverStatus = .tutorialDone
    gameState.enter(GameOver.self)
    return
  }
  
  private func handleHeroHeroCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
    guard !(gameState.currentState is Tutorial) else { return }
    
    guard let firstHeroNode = firstBody.node as? SKSpriteNode,
      let secondHeroNode = secondBody.node as? SKSpriteNode else { return }
    
    guard let firstHero = entityManager.heroWith(node: firstHeroNode) as? General,
      let firstHeroSpriteComponent = firstHero.component(ofType: SpriteComponent.self),
      let firstHeroHandsComponent = firstHero.component(ofType: HandsComponent.self),
      let secondHero = entityManager.heroWith(node: secondHeroNode) as? General,
      let secondHeroHandsComponent = secondHero.component(ofType: HandsComponent.self),
      !firstHeroHandsComponent.isImpacted && !secondHeroHandsComponent.isImpacted else { return }
    
    firstHero.impactedAt(point: firstHeroSpriteComponent.node.position)
    secondHero.impactedAt(point: firstHeroSpriteComponent.node.position)
    
    audioPlayer.play(effect: Audio.EffectFiles.playerCollision)
    
//    multiplayerNetworking.sendImpacted(senderIndex: 0)
//    multiplayerNetworking.sendImpacted(senderIndex: 1)
  }
  
  private func handleHeroPackageCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
    guard let heroNode = firstBody.node as? SKSpriteNode,
      let resourceNode = secondBody.node as? SKShapeNode else { return }
    
    guard let hero = entityManager.heroWith(node: heroNode) as? General,
      let impactedResource = entityManager.resourceWith(node: resourceNode) as? Package else { return }
    
    guard let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
      let heroHandsComponent = hero.component(ofType: HandsComponent.self),
      let resourceShapeComponent = impactedResource.component(ofType: ShapeComponent.self),
      !heroHandsComponent.isImpacted else { return }
    
    guard let throwButton = cam?.childNode(withName: AppConstants.ButtonNames.throwButtonName) else { return }
    
    if heroHandsComponent.hasFreeHand {
      heroHandsComponent.grab(resource: impactedResource)
      
      // enable the throw button if this is the main hero
      if hero == entityManager.hero {
        throwButton.alpha = 1.0
      }
      
      if let resourceIndex = entityManager.indexForResource(shape: resourceShapeComponent.node),
        let heroIndex = entityManager.playerEntites.firstIndex(of: hero) {
      
//        multiplayerNetworking
//          .sendGrabbedResource(index: resourceIndex,
//                               playerIndex: heroIndex,
//                               senderIndex: entityManager.currentPlayerIndex)
      }
      hero.updateResourcePositions()
      
      let effect = heroHandsComponent.rightHandSlot == nil ?
        Audio.EffectFiles.collectResource1 : Audio.EffectFiles.collectResource1
      audioPlayer.play(effect: effect)
    } else {
      hero.impactedAt(point: heroSpriteComponent.node.position)
      
      // disable the throw button
      throwButton.alpha = 0.5
      
      audioPlayer.play(effect: Audio.EffectFiles.collisionLoseResource)
    }
  }
  
  private func handleHeroDepositCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
    guard let heroNode = firstBody.node as? SKSpriteNode,
      let depositNode = secondBody.node as? SKShapeNode else { return }
    
    guard let hero = entityManager.heroWith(node: heroNode) as? General,
      let deposit = entityManager.enitityWith(node: depositNode) as? Deposit else { return }
    
    guard let handsComponent = hero.component(ofType: HandsComponent.self),
      let teamComponent = hero.component(ofType: TeamComponent.self),
      let aliasComponent = hero.component(ofType: AliasComponent.self),
      let deliveredComponent = hero.component(ofType: DeliveredComponent.self),
      let depositComponent = deposit.component(ofType: DepositComponent.self),
      (handsComponent.leftHandSlot != nil || handsComponent.rightHandSlot != nil) else { return }
    
    if let lefthanditem = handsComponent.leftHandSlot,
      let shapeComponent = lefthanditem.component(ofType: ShapeComponent.self) {
      
      handsComponent.release(resource: lefthanditem)
      shapeComponent.node.removeFromParent()
    
      deliveredComponent.resources.insert(lefthanditem)
    }
    
    if let rightHandItem = handsComponent.rightHandSlot,
      let shapeComponent = rightHandItem.component(ofType: ShapeComponent.self) {
      
      handsComponent.release(resource: rightHandItem)
      shapeComponent.node.removeFromParent()
      
      deliveredComponent.resources.insert(rightHandItem)
    }
    
    var heroAlias: String
    if hero == entityManager.playerEntites[0] {
      heroAlias = getPlayerAliasAt(index: 0)
    } else {
      heroAlias = getPlayerAliasAt(index: 1)
    }
    aliasComponent.node.text = "\(heroAlias) (\(hero.numberOfDeposits)/\(EntityManager.Constants.resourcesNeededToWin))"
    
    switch teamComponent.team {
    case .team1: depositComponent.team1Deposits = hero.numberOfDeposits
    case .team2: depositComponent.team2Deposits = hero.numberOfDeposits
    default: break
    }
    
    if let label = gameMessage {
      label.text = "Deposit"
      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    }
    
    ShapeFactory.shared.spawnDepositParticleEffect(pos: depositNode.position)
    audioPlayer.play(effect: Audio.EffectFiles.youScored)
  }
  
  private func handleHeroWallCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
    guard let heroNode = firstBody.node as? SKSpriteNode,
      let beam = secondBody.node as? SKShapeNode else { return }
    
    guard let hero = entityManager.heroWith(node: heroNode) as? General,
      let spriteComponent = hero.component(ofType: SpriteComponent.self),
      let physicsComponent = hero.component(ofType: PhysicsComponent.self),
      let impulseComponent = hero.component(ofType: ImpulseComponent.self),
      let launchComponent = hero.component(ofType: LaunchComponent.self),
      let panel = entityManager.panelWith(node: beam) as? Panel,
      let panelShapeComponent = panel.component(ofType: ShapeComponent.self),
      let tractorBeamComponent = panel.component(ofType: BeamComponent.self),
      gameState.currentState is Tutorial || !tractorBeamComponent.isOccupied,
      hero.isBeamable else { return }
    
    if let panelTeamComponent = panel.component(ofType: TeamComponent.self),
      let heroTeamComponent = hero.component(ofType: TeamComponent.self),
      panelTeamComponent.team != heroTeamComponent.team,
      gameState.currentState is Tutorial,
      hero !== entityManager.playerEntites[1],
      let tutorial = entityManager.tutorialEntities[0] as? TutorialAction {
      
      if let step = tutorial.setupNextStep(), step == .rotateThrow {
        entityManager.spawnResource(position: step.midPosition, velocity: .zero)
      }
      
      return
    }
    
    physicsComponent.isEffectedByPhysics = false
    
    let isTopBeam = beam.position.y == abs(beam.position.y)
    let convertedPosition = convert(beam.position, from: panelShapeComponent.node)
    let rotation = isTopBeam ?
      panelShapeComponent.node.zRotation :
      panelShapeComponent.node.zRotation + CGFloat.pi
    
    DispatchQueue.main.async {
      spriteComponent.node.position = convertedPosition
      spriteComponent.node.zRotation = rotation
    }
    
    hero.switchToState(.beamed)
    if hero == entityManager.playerEntites[entityManager.currentPlayerIndex] {
      let launchLineNode = launchComponent.node.childNode(withName: AppConstants.ComponentNames.launchLineName) as? SKShapeNode
      launchLineNode?.alpha = LaunchComponent.targetLineAlpha
    }
    
    hero.occupiedPanel = panel
    tractorBeamComponent.isOccupied = true
    
    //      if let index = entityManager.indexForWall(panel: panel) {
    //        multiplayerNetworking.sendWall(index: index, isOccupied: true)
    //      }
    impulseComponent.isOnCooldown = false
    
    if hero != entityManager.playerEntites[1] {
      audioPlayer.play(effect: Audio.EffectFiles.blipSound)
    }
  }
  
}

private extension SKPhysicsContact {
  
  var physicsBodies: (first: SKPhysicsBody, second: SKPhysicsBody) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    
    if self.bodyA.categoryBitMask < self.bodyB.categoryBitMask {
      firstBody = self.bodyA
      secondBody = self.bodyB
    } else {
      firstBody = self.bodyB
      secondBody = self.bodyA
    }
    
    return (firstBody, secondBody)
  }
  
}
