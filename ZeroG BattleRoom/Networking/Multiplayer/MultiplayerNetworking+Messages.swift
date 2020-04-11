//
//  Multiplayer+Messages.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/31/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


extension MultiplayerNetworking {
  typealias SnapshotElementGroup = [MessageSnapshotElement]
  
  enum MessageType: Int, Codable  {
    case randomeNumber
    case gameBegin
    case move
    case moveResource
    case impacted
    case grabResource
    case gameOver
    case snapshot
  }
  
  struct Message: Codable {
    let type: MessageType
  }
  
//  struct MessageRandomNumber: Codable {
//    let mesage: Message
//    let randomNumber: Double
//  }
//  
//  struct MessageGameBegin: Codable {
//    let mesage: Message
//  }
//  
//  struct MessageMove: Codable {
//    let mesage: Message
//    let position: CGPoint
//    let vector: CGVector
//  }
//  
//  struct MessageGameOver: Codable {
//    let message: Message
//    let player1Won: Bool
//  }
//  
//  struct MessageSnapshot: Codable {
//    let message: Message
//    let elements: [SnapshotElementGroup]
//  }
  
  struct MessageSnapshotElement: Codable {
    let position: CGPoint
    let vector: CGVector
  }
}

extension MultiplayerNetworking {
  struct UnifiedMessage: Codable {
    let type: MessageType
    let randomNumber: Double?
    let player1Won: Bool?
    let resourceIndex: Int?
    let playerIndex: Int?
    let elements: [SnapshotElementGroup]?
    
    init(type: MessageType,
         randomNumber: Double? = nil,
         player1Won: Bool? = nil,
         resourceIndex: Int? = nil,
         playerIndex: Int? = nil,
         elements: [SnapshotElementGroup]? = nil) {
      self.type = type
      self.randomNumber = randomNumber
      self.player1Won = player1Won
      self.resourceIndex = resourceIndex
      self.playerIndex = playerIndex
      self.elements = elements
    }
  }
}

extension MultiplayerNetworkingSnapshot {
  enum GroupIndecies: Int, CaseIterable {
    case players
    case resources
  }
}
