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
  
  func aspectFillToSize(fillSize: CGSize) {
    if self.texture != nil {
//      self.size = self.texture!.size()
      
      let verticalRatio = fillSize.height / self.texture!.size().height
      let horizontalRatio = fillSize.width /  self.texture!.size().width
      let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio
      
      self.setScale(scaleRatio)
    }
  }
}
