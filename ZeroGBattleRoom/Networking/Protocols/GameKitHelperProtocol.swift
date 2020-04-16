//
//  GameKitHelperProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameKit

protocol GameKitHelperDelegate {
  func matchStarted()
  func matchEnded()
  func match(_ match: GKMatch, didReceive data: Data, from player: GKPlayer)
}
