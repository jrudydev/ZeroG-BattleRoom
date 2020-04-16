//
//  LaunchableProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/12/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation


protocol LaunchableProtocol {
  func launch(vacateWall: (Panel) -> Void)
}
