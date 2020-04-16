//
//  SoundManager.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/27/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

class SoundManager {
  private init() {}
  
  static let shared = SoundManager()
  
  let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
  let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
  let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
  let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
  let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
}
