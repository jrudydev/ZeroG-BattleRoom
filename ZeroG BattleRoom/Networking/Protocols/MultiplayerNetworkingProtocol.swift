//
//  MultiplayerNetworkingProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation

protocol MultiplayerNetworkingProtocol {
  func matchEnded()
  func setCurrentPlayer(index: Int)
}
