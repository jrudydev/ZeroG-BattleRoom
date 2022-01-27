//
//  GameScene+Multiplayer.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 1/31/21.
//  Copyright © 2021 JRudy Gaming. All rights reserved.
//

import SpriteKit

extension GameScene: MultiplayerNetworkingProtocol {
  func matchEnded() {
    gameOverStatus = .disconnected
    gameState.enter(GameOver.self)
    GameKitHelper.shared.match?.disconnect()
    GameKitHelper.shared.match = nil
  }
  
  func setPlayerAliases(playerAliases: [String]) {
    for (idx, alias) in playerAliases.enumerated() {
      let entity = entityManager.playerEntities[idx]
      if let aliasComponent = entity.component(ofType: AliasComponent.self) {
        aliasComponent.node.text = "\(alias) (0/\(EntityManager.Constants.resourcesNeededToWin))"
      }
    }
  }
  
  func movePlayerAt(index: Int,
                    position: CGPoint,
                    rotation: CGFloat,
                    velocity: CGVector,
                    angularVelocity: CGFloat,
                    wasLaunch: Bool) {
    if let player = entityManager.playerEntities[index] as? General,
      let spriteComponent = player.component(ofType: SpriteComponent.self),
      let physicsComponent = player.component(ofType: PhysicsComponent.self),
      let impulseComponent = player.component(ofType: ImpulseComponent.self) {
       
      spriteComponent.node.zRotation = rotation
      spriteComponent.node.position = position

      player.switchToState(.moving)
      if wasLaunch,
        let beamComponent = player.occupiedPanel?.component(ofType: BeamComponent.self) {
        
        beamComponent.isOccupied = false
      } else {
        guard !impulseComponent.isOnCooldown else { return }
  
        impulseComponent.isOnCooldown = true
      }
      
      
      DispatchQueue.main.async {
        physicsComponent.physicsBody.velocity = velocity
        physicsComponent.physicsBody.angularVelocity = angularVelocity
      }
    }
  }
  
  func syncPlayerAt(index: Int,
                    position: CGPoint,
                    rotation: CGFloat,
                    velocity: CGVector,
                    angularVelocity: CGFloat,
                    resourceIndecies: [Int]) {
    if let player = entityManager.playerEntities[index] as? General,
      let spriteComponent = player.component(ofType: SpriteComponent.self),
      let physicsComponent = player.component(ofType: PhysicsComponent.self) {
      
      spriteComponent.node.position = position
      spriteComponent.node.zRotation = rotation
      physicsComponent.physicsBody.velocity = velocity
      physicsComponent.physicsBody.angularVelocity = angularVelocity
    }
  }
  
//  func moveResourceAt(index: Int,
//                      position: CGPoint,
//                      rotation: CGFloat,
//                      velocity: CGVector,
//                      angularVelocity: CGFloat) {
//    if let package = entityManager.resourcesEntities[index] as? Package,
//      let shapeComponent = package.component(ofType: ShapeComponent.self),
//      let physicsComponent = package.component(ofType: PhysicsComponent.self) {
//
//      shapeComponent.node.position = position
//      shapeComponent.node.zRotation = rotation
//      physicsComponent.physicsBody.velocity = velocity
//      physicsComponent.physicsBody.angularVelocity = angularVelocity
//    }
//  }
  
  func syncResourceAt(index: Int,
                      position: CGPoint,
                      rotation: CGFloat,
                      velocity: CGVector,
                      angularVelocity: CGFloat) {
    if let package = entityManager.resourcesEntities[index] as? Package,
      let shapeComponent = package.component(ofType: ShapeComponent.self),
      let physicsComponent = package.component(ofType: PhysicsComponent.self) {
      
      shapeComponent.node.position = position
      shapeComponent.node.zRotation = rotation
      physicsComponent.physicsBody.velocity = velocity
      physicsComponent.physicsBody.angularVelocity = angularVelocity
    }
  }
  
  func syncPlayerResources(players: MultiplayerNetworking.SnapshotElementGroup) {
    for (idx, playerSnap) in players.enumerated() {
      if let player = entityManager.playerEntities[idx] as? General,
        let handsComponent = player.component(ofType: HandsComponent.self),
        let deliveredComponent = player.component(ofType: DeliveredComponent.self) {
        
        // Check the left hand
        if playerSnap.resourceIndecies.count >= 1 {
          let index = playerSnap.resourceIndecies[0]
          let heldResource = entityManager.resourcesEntities[index] as! Package
          
          if let leftHandSlot = handsComponent.leftHandSlot {
            if heldResource != leftHandSlot {
              handsComponent.release(resource: leftHandSlot)
              handsComponent.grab(resource: heldResource)
            }
          } else {
            handsComponent.grab(resource: heldResource)
          }
        } else if let leftHandSlot = handsComponent.leftHandSlot {
          handsComponent.release(resource: leftHandSlot)
        }
        
        // Check the right hand
        if playerSnap.resourceIndecies.count >= 2 {
          let index = playerSnap.resourceIndecies[1]
          let heldResource = entityManager.resourcesEntities[index] as! Package
          
          if let rightHandSlot = handsComponent.rightHandSlot {
            if heldResource != rightHandSlot {
              handsComponent.release(resource: rightHandSlot)
              handsComponent.grab(resource: heldResource)
            }
          } else {
            handsComponent.grab(resource: heldResource)
          }
        } else if let rightHandSlot = handsComponent.rightHandSlot {
          handsComponent.release(resource: rightHandSlot)
        }
        
        // Check scored resources
        var scoredResources = Set<Package>()
        for index in playerSnap.scoredResourceIndecies {
          let resource = entityManager.resourcesEntities[index] as! Package
          
          guard let resourceShapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
          
          if entityManager.isScored(resource: resource) {
            resourceShapeComponent.node.removeFromParent()
          }
          
          scoredResources.insert(resource)
        }
        
        deliveredComponent.resources = scoredResources
      }
    }
  }
  
  func syncResources(resources: MultiplayerNetworking.SnapshotElementGroup) {
    for x in entityManager.resourcesEntities.count..<resources.count {
      entityManager.spawnResource(position: resources[x].position,
                                       velocity: resources[x].velocity)
    }
  }
  
//  func impactPlayerAt(senderIndex: Int) {
//    if let hero = entityManager.playerEntities[senderIndex] as? General,
//      let spriteComponent = hero.component(ofType: SpriteComponent.self),
//      let heroHandsComponent = hero.component(ofType: HandsComponent.self),
//      !heroHandsComponent.isImpacted {
//
//      print("Hero at index: \(senderIndex) impacted!!!!")
//      hero.impactedAt(point: spriteComponent.node.position)
//    }
//  }
//
//  func grabResourceAt(index: Int, playerIndex: Int, senderIndex: Int) {
//    let senderEntity = entityManager.playerEntities[senderIndex]
//    let playerEntity = entityManager.playerEntities[playerIndex]
//
//    guard let playerHandsComponent = playerEntity.component(ofType: HandsComponent.self),
//      let resource = entityManager.resourcesEntities[index] as? Package,
//      let resourceShapeComponent = resource.component(ofType: ShapeComponent.self),
//      !playerHandsComponent.isHolding(shapeComponent: resourceShapeComponent) else { return }
//
//    if senderEntity == entityManager.playerEntities[0] {
//      for player in entityManager.playerEntities {
//        guard player != playerEntity else { continue }
//        guard let handsComponent = player.component(ofType: HandsComponent.self) else { continue }
//
//        if handsComponent.isHolding(shapeComponent: resourceShapeComponent) {
//          // If so release and send correction back to client
//          handsComponent.release(resource: resource)
//
////          multiplayerNetworking.sendAssignResource(index: index, playerIndex: playerIndex)
//
//          return
//        }
//      }
//    } else {
//      for player in entityManager.playerEntities {
//        guard player != playerEntity else { continue }
//        guard let handsComponent = player.component(ofType: HandsComponent.self) else { continue }
//
//        if handsComponent.isHolding(shapeComponent: resourceShapeComponent) {
//          handsComponent.release(resource: resource, point: resourceShapeComponent.node.position)
//          break
//        }
//      }
//
//    }
//    playerHandsComponent.grab(resource: resource)
//  }
//
//  func assignResourceAt(index: Int, playerIndex: Int) {
//    guard let hero = entityManager.hero as? General,
//      let heroHandscomponent = hero.component(ofType: HandsComponent.self),
//      let player = entityManager.playerEntities[playerIndex] as? General,
//      let playerHandsComponent = player.component(ofType: HandsComponent.self),
//      let package = entityManager.resourcesEntities[index] as? Package else { return }
//
//    heroHandscomponent.release(resource: package)
//    playerHandsComponent.grab(resource: package)
//  }
//
//  func syncWallAt(index: Int, isOccupied: Bool) {
//    guard let beamComponent = entityManager.wallEntities[index].component(ofType: BeamComponent.self) else { return }
//
//    beamComponent.isOccupied = isOccupied
//  }
  
  func gameOver(player1Won: Bool) {
    gameOverStatus = !player1Won ? .gameWon : .gameLost
  }
  
  func setCurrentPlayerAt(index: Int) {
    entityManager.currentPlayerIndex = index
    gameState.enter(MatchFound.self)
  
    SnapshotManager.shared.isSendingSnapshots = true
  }
}
