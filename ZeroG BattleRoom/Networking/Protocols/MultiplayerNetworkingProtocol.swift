//
//  MultiplayerNetworkingProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

protocol MultiplayerNetworkingProtocol {
  func movePlayerAt(index: Int, position: CGPoint, direction: CGVector)
  func impactPlayer(player: GKPlayer)
  func syncPlayerAt(index: Int, position: CGPoint, vector: CGVector)
  func moveResourceAt(index: Int, position: CGPoint, vector: CGVector)
  func syncResources(resources: MultiplayerNetworking.SnapshotElementGroup)
  func syncResourceAt(index: Int, position: CGPoint, vector: CGVector)
  func grabResourceAt(index: Int, playerIndex: Int, player: GKPlayer)
  func assignResourceAt(index: Int, playerIndex: Int)
  func gameOver(player1Won: Bool)
  func setCurrentPlayerAt(index: Int)
  func setPlayerAliases(playerAliases: [String])
}
