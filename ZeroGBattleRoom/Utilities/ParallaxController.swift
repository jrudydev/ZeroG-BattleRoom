//
//  ParallaxController.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 7/10/21.
//  Copyright © 2021 JRudy Gaming. All rights reserved.
//

import SpriteKit


class ParallaxController {
  
  struct Dimension {
    
    var layer: SKSpriteNode
    var distance: CGFloat

    func update(with focus: SKSpriteNode) {
      let positionX = focus.position.x * -1 / distance
      let positionY = focus.position.y * -1 / distance
      layer.position = CGPoint(x: positionX, y: positionY)
    }
    
  }
  
  var focus: SKSpriteNode? = nil
  var demensions: [Dimension] = []
  
  func add(_ dimension: Dimension) {
    demensions.append(dimension)
  }
  
  func update() {
    guard let focus = focus else { return }
    
    demensions.forEach { demension in
      demension.update(with: focus)
    }
  }
  
}
