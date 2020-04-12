//
//  ImpulsableProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/12/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


protocol ImpulsableProtocol {
  func impulseTo(location: CGPoint, completion: (SKSpriteNode, CGVector) -> Void)
}
