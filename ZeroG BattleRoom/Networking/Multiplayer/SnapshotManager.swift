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
  
  enum ElementIndex: Int, CaseIterable {
    case localPlayer
    case remotePlayer
  }

  let publisher: AnyPublisher<[(CGPoint, CGVector)], Never>
  var isSendingSnapshots = false

  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  private var subscriptions = Set<AnyCancellable>()

  unowned var scene: GameScene?
  
  static let shared = MultiplayerNetworkingSnapshot()
  
  private init() {
    let subject = PassthroughSubject<[(CGPoint, CGVector)], Never>()
    self.publisher = subject.eraseToAnyPublisher()
    
    self.timer
      .sink { _ in
        guard self.isSendingSnapshots,
          let players = self.scene?.players else { return }
        
        var elements = [(CGPoint, CGVector)]()
        for player in players {
          elements.append((player.position,
                            player.physicsBody?.velocity ?? CGVector.zero))
        }
        subject.send(elements)
      }
      .store(in: &subscriptions)
  }
}
