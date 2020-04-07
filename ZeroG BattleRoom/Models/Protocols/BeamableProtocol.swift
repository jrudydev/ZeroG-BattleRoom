//
//  BeamableProtocol.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

protocol BeamableProtocol {
  static var beamResetTime: Double { get }
  
  var isBeamed: Bool { get }
  var beam: SKShapeNode? { get set }
  
  func resetBeamTimer()
}
