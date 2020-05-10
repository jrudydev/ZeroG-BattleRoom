//
//  SKSpriteNode+Texture.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 5/10/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


extension SKSpriteNode {
  func setTexture(imageNamed: String) {
    let magnitudeTexture = SKTexture(imageNamed: imageNamed)
    self.texture = magnitudeTexture
    self.size = self.texture!.size()
  }
}

