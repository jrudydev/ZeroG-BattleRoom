//
//  SnapshotManager.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/30/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import Combine
import SpriteKit


class SnapshotManager {

  static private let frequency = 1.0 / 30.0
  
  let publisher: AnyPublisher<[MultiplayerNetworking.SnapshotElementGroup], Never>
  var isSendingSnapshots = false
  var includeResources = false
  
  var playerysInfo: MultiplayerNetworking.SnapshotElementGroup {
    guard let entities = self.scene?.entityManager.playerEntites else { return [] }
    
    var info = MultiplayerNetworking.SnapshotElementGroup()
    for entity in entities {
      if let spriteComponent = entity.component(ofType: SpriteComponent.self),
        let physicsComponent = entity.component(ofType: PhysicsComponent.self),
        let handsComponent = entity.component(ofType: HandsComponent.self) {
        
        var resourceIndecies = [Int]()
        if let leftHandResource = handsComponent.leftHandSlot,
          let resourceShapeComponent = leftHandResource.component(ofType: ShapeComponent.self),
          let resourceIndex = self.scene?.entityManager.indexForResource(shape: resourceShapeComponent.node) {
          
          resourceIndecies.append(resourceIndex)
        }
        if let rightHandResource = handsComponent.rightHandSlot,
          let resourceShapeComponent = rightHandResource.component(ofType: ShapeComponent.self),
          let resourceIndex = self.scene?.entityManager.indexForResource(shape: resourceShapeComponent.node) {
          
          resourceIndecies.append(resourceIndex)
        }
      
        let snapshot = MultiplayerNetworking.MessageSnapshotElement(
          position: spriteComponent.node .position,
          rotation: spriteComponent.node.zRotation,
          velocity: physicsComponent.physicsBody.velocity,
          angularVelocity: physicsComponent.physicsBody.angularVelocity,
          resourceIndecies: resourceIndecies)
        info.append(snapshot)
      }
    }
    
    return info
  }
  
  var resourcesInfo: MultiplayerNetworking.SnapshotElementGroup {
    guard let entities = self.scene?.entityManager.resourcesEntities else { return [] }
    
    var info = MultiplayerNetworking.SnapshotElementGroup()
    for entity in entities {
      if let shapeComponent = entity.component(ofType: ShapeComponent.self),
        let physicsComponent = entity.component(ofType: PhysicsComponent.self) {
        
        let snapshot = MultiplayerNetworking.MessageSnapshotElement(
          position: shapeComponent.node.position,
          rotation: shapeComponent.node.zRotation,
          velocity: physicsComponent.physicsBody.velocity,
          angularVelocity: physicsComponent.physicsBody.angularVelocity)
        info.append(snapshot)
      }
    }
    
    return info
  }

  private let timer = Timer.publish(every: SnapshotManager.frequency,
                                    on: .main,
                                    in: .common).autoconnect()
  private var subscriptions = Set<AnyCancellable>()

  unowned var scene: GameScene?
  
  static let shared = SnapshotManager()
  
  private init() {
    let subject = PassthroughSubject<[MultiplayerNetworking.SnapshotElementGroup], Never>()
    self.publisher = subject.eraseToAnyPublisher()
    
    self.timer
      .sink { _ in
        guard self.isSendingSnapshots else { return }
          
        let elements = self.includeResources ?
          [self.playerysInfo, self.resourcesInfo] : [self.playerysInfo, []]
        
//        print("Sending snapshot: \(elements)")
        subject.send(elements)
      }
      .store(in: &subscriptions)
  }
}
