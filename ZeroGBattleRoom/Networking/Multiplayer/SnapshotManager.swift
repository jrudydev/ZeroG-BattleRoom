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


class MultiplayerNetworkingSnapshot {

  static private let frequency = 1.0 / 30.0
  
  let publisher: AnyPublisher<[MultiplayerNetworking.SnapshotElementGroup], Never>
  var isSendingSnapshots = false
  var includeResources = false
  
  var playerysInfo: MultiplayerNetworking.SnapshotElementGroup {
    guard let entities = self.scene?.entityManager.playerEntites else { return [] }
    
    var info = MultiplayerNetworking.SnapshotElementGroup()
    for entity in entities {
      if let spriteComponent = entity.component(ofType: SpriteComponent.self),
        let physicsComponent = entity.component(ofType: PhysicsComponent.self) {
      
        let snapshot = MultiplayerNetworking.MessageSnapshotElement(
          position: spriteComponent.node .position,
          rotation: spriteComponent.node.zRotation,
          velocity: physicsComponent.physicsBody.velocity,
          angularVelocity: physicsComponent.physicsBody.angularVelocity)
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

  private let timer = Timer.publish(every: MultiplayerNetworkingSnapshot.frequency,
                                    on: .main,
                                    in: .common).autoconnect()
  private var subscriptions = Set<AnyCancellable>()

  unowned var scene: GameScene?
  
  static let shared = MultiplayerNetworkingSnapshot()
  
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
