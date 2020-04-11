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
    let isPlayer1: Bool?
    let index: Int?
    let elements: [SnapshotElementGroup]?
    
    init(type: MessageType,
         randomNumber: Double? = nil,
         isPlayer1: Bool? = nil,
         index: Int? = nil,
         elements: [SnapshotElementGroup]? = nil) {
      self.type = type
      self.randomNumber = randomNumber
      self.isPlayer1 = isPlayer1
      self.index = index
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
