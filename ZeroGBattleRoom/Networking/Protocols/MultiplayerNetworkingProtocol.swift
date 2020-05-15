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
  func matchEnded()
  func movePlayerAt(index: Int,
                    position: CGPoint,
                    rotation: CGFloat,
                    velocity: CGVector,
                    angularVelocity: CGFloat,
                    wasLaunch: Bool)
 func syncPlayerAt(index: Int,
                   position: CGPoint,
                   rotation: CGFloat,
                   velocity: CGVector,
                   angularVelocity: CGFloat,
                   resourceIndecies: [Int])
//  func moveResourceAt(index: Int,
//                      position: CGPoint,
//                      rotation: CGFloat,
//                      velocity: CGVector,
//                      angularVelocity: CGFloat)
  func syncResourceAt(index: Int,
                      position: CGPoint,
                      rotation: CGFloat,
                      velocity: CGVector,
                      angularVelocity: CGFloat)
  func syncPlayerResources(players: MultiplayerNetworking.SnapshotElementGroup)
  func syncResources(resources: MultiplayerNetworking.SnapshotElementGroup)
//  func impactPlayerAt(senderIndex: Int)
//  func grabResourceAt(index: Int, playerIndex: Int, senderIndex: Int)
//  func assignResourceAt(index: Int, playerIndex: Int)
//  func syncWallAt(index: Int, isOccupied: Bool)
  func gameOver(player1Won: Bool)
  func setCurrentPlayerAt(index: Int)
  func setPlayerAliases(playerAliases: [String])
}
