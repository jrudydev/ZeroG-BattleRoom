//
//  SKNode+Impulse.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/25/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
  func randomeImpulse() {
    let randomX = (Bool.random() ? -1 : 1) * (Double.random(in: 1...2))
    let randomY = (Bool.random() ? -1 : 1) * (Double.random(in: 1...2))
    self.physicsBody?.applyImpulse(CGVector(dx: randomX, dy: randomY))
    self.physicsBody?.applyAngularImpulse(0.01)
  }
}
