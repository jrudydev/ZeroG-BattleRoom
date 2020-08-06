//
//  File.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation


struct Audio {
  struct MusicFiles {
    static let level = Music(name: "zerog-loop", ext: "mp3")
  }
  
  struct EffectFiles {
    static let startGame = Effect(name: "start-game", ext: "wav")
    static let throwResource = Effect(name: "throwing-resource", ext: "wav")
    static let youScored = Effect(name: "you-scored", ext: "wav")
    static let collectResource1 = Effect(name: "collect-resource-1", ext: "wav")
    static let collectResource2 = Effect(name: "collect-resource-2", ext: "wav")
    static let collisionLoseResource = Effect(name: "collision-lose-resource", ext: "wav")
    static let uiMenuSelect = Effect(name: "ui-menu-select", ext: "wav")
    static let readyToLaunch = Effect(name: "ready-to-launch", ext: "wav")
    static let playerCollision = Effect(name: "player-collision", ext: "wav")
    static let blipSound = Effect(name: "pongblip", ext: "wav")
  }
}
