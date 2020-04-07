//
//  SpriteComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
  let node: SKSpriteNode
  
  init(texture: SKTexture) {
    self.node = SKSpriteNode(texture: texture, color: .white, size: texture.size())
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
