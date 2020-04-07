//
//  ImpulsableProtocol.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

protocol ImpulsableProtocol {
  var impulseCooldown: Double { get }
  var isImpulseOnCooldown: Bool { get }
  
  func impulse(vector: CGVector)
}
