//
//  BeamableProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/19/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


protocol BeamableProtocol {
  var beam: SKShapeNode? { get set }
  var isBeamed: Bool { get }
  var isBeamable: Bool { get }
  func resetBeamTimer()
}
