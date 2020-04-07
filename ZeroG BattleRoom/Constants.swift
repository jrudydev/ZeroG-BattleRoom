//
//  Constants.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/24/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

struct AppConstants {
  struct Layout {
    static var mapSize = CGSize(width: 2000, height: 3000)
    static var boundarySize = CGSize(width: 1000, height: 1500)
    static var wallSize = CGSize(width: 100, height: 20)
    static var wallCornerRadius: CGFloat {
      return wallSize.width * 0.1
    }
  }
  
  struct ComponentNames {
    static let heroPlayerName = "hero-player"
    static let gameMessageName = "game-message"
    static let playerAliasLabelName = "player-alias"
    static let resourceName = "resource-name"
  }
}

extension CGSize {
  var randomPosition: CGPoint {
    let halfWidth = (self.width - 50) / 2
    let halfHeight = (self.height - 50) / 2

    return CGPoint(x: CGFloat.random(in: -halfWidth...halfWidth),
                   y: CGFloat.random(in: -halfHeight...halfHeight))
  }
}
