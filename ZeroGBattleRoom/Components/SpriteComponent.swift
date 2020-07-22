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


enum SpriteZPosition: CGFloat {
  case deepSpace  = -100
  case station    = -50
  case arena      = -30
  case background = -20
  case simulation = -19
  case particles  = 10
  case hero       = 20
  case inGameUI   = 40
  case menu       = 100
  case menuLabel  = 101
}


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
