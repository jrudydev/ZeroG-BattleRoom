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
    static var boundarySize = CGSize(width:  1000, height: 1600)
    static var tutorialBoundrySize = CGSize(width: 100.0, height: 400.0)
    static var wallSize = CGSize(width: 100, height: 20)
    static var wallCornerRadius: CGFloat {
      return wallSize.width * 0.1
    }
  }
  
  struct ComponentNames {
    static let heroPlayerName = "hero-player"
    static let menuImageName = "munu-image"
    static let gridImageName = "grid-image"
    static let localLabelName = "tutorial-label"
    static let tutorialLabelName = "local-label"
    static let onlineLabelName = "online-label"
    static let shopLabelName = "shop-label"
    static let backButtonName = "back-button"
    static let gameOverLabel = "game-over-label"
    static let wallPanelName = "wall-panel"
    static let gameMessageName = "game-message"
    static let playerAliasLabelName = "player-alias"
    static let resourceName = "resource-name"
    static let launchLineName = "launch-line"
    static let targetLineName = "target-line"
    static let targetBaseLineName = "target-base-line"
    static let targetMidCircleName = "target-mid-circle"
    static let targetChevronName = "target-chevron-name"
    static let targetLeftChevronName = "target-left-chevron-name"
    static let targetRightChevronName = "target-right-chevron-name"
    static let magnitudePilarName = "magnitude-pilar"
    static let rotationCircleName = "rotation-circle"
    static let ingameUIViewName = "ingame-ui-view"
    static let spinnyNodeName = "spinny-node"
  }
  
  struct Touch {
    static let maxSwipeDistance: CGFloat = 100.0
    static let maxRotation: CGFloat = 100.0
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
