//
//  TractorBeamsComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/7/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class TracktorBeamComponent: GKComponent {
  
  let beams: [SKShapeNode]
  var isOccupied = false
  
  init(nodes: [SKShapeNode]) {
    self.beams = nodes
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
