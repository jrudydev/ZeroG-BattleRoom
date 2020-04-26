//
//  LaunchableProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/12/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


protocol LaunchableProtocol {
  func launch(completion: (SKSpriteNode, CGVector, Panel) -> Void) 
}
