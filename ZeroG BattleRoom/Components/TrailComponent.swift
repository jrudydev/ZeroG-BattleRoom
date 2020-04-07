//
//  TrailComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class TrailComponent: GKComponent {
  
  let node = SKNode()
  let emitter = SKEmitterNode(fileNamed: "BallTrail")
  
  override init() {
    super.init()
    
    self.emitter?.targetNode = self.node
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
