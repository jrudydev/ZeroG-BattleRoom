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
  
  struct UIColors {
    static let buttonBackground = UIColor(named: "BtnBackground") ?? .gray
    static let buttonForeground = /*UIColor(named: "BtnForegroundGreen") ??*/ UIColor.white
  }
  
  struct Layout {
    static let mapSize = CGSize(width: 2000, height: 3000)
    static let boundarySize = CGSize(width:  1100, height: 1600)
    static let tutorialBoundrySize = CGSize(width: 100.0, height: 400.0)
    static let wallSize = CGSize(width: 100, height: 20)
    static var wallCornerRadius: CGFloat {
      return wallSize.width * 0.1
    }
    static let innerDistance: CGFloat = 200.0
    static let buttonWidth: CGFloat = 50.0
    static let buttonCornerRadius: CGFloat = 10.0
    static let buttonOrigin = CGPoint(x: -buttonWidth/2, y:  -buttonWidth/2)
    static let buttonSize = CGSize(width: buttonWidth, height: buttonWidth)
    static let buttonRect = CGRect(origin: buttonOrigin, size: buttonSize)
  }
  
  struct ComponentNames {
    static let heroPlayerName = "hero-player"
    static let menuImageName = "munu-image"
    static let menuBackgroundName = "menu-background"
    static let gameBackgroungName = "universe"
    static let gridImageName = "grid-image"
    static let localLabelName = "local-label"
    static let tutorialLabelName = "tutorial-label"
    static let onlineLabelName = "online-label"
    static let shopLabelName = "shop-label"
    
    static let gameOverLabel = "game-over-label"
    static let matchFoundLabel = "match-found-label"
    static let matchFoundVSLabel = "match-found-vs-label"
    static let matchFoundPlayer1Label = "match-found-player1-label"
    static let matchFoundPlayer2Label = "match-found-player2-label"
    static let matchFoundStartsInLabel = "match-found-starts-in-label"
    static let matchFoundCountDownLabel = "match-found-count-down-label"
    static let wallPanelName = "wall-panel"
    static let gameMessageName = "game-message"
    static let playerAliasLabelName = "player-alias"
    static let resourceName = "resource-name"
    static let launchLineName = "launch-line"
    static let targetLineName = "target-line"
    static let targetBaseLineName = "target-base-line"
    static let targetMidCircleName = "target-mid-circle"
    static let targetLeftChevronName = "target-left-chevron-name"
    static let targetRightChevronName = "target-right-chevron-name"
    static let magnitudePilarName = "magnitude-pilar"
    static let rotationCircleName = "rotation-circle"
    static let spinnyNodeName = "spinny-node"
    static let depositNodeName = "deposit-node"
    
    static let tutorialStartPointName = "start-point"
    static let tutorialTapPointName = "tap-point"
    static let tutorialTapStickerName = "tap-sticker"
    static let tutorialPinchStickerName = "pinch-sticker"
    static let tutorialThrowStickerName = "throw-sticker"
  }
  
  struct StickerNames {
    
  }
  
  struct ButtonNames {
    static let throwButtonName = "throw-button"
    static let backButtonName = "back-button"
    static let refreshButtonName = "refresh-button"
    
    static let all: Set<String> = [
      Self.throwButtonName,
      Self.backButtonName,
      Self.refreshButtonName
    ]
  }
  
  struct Touch {
    static let maxSwipeDistance: CGFloat = 100.0
    static let maxRotation: CGFloat = 100.0
  }
  
}
