//
//  AudioPlayerProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation


public protocol AudioPlayerProtocol {
  var musicVolume: Float { get set }
  func play(music: Music)
  func pause(music: Music)
  
  var sfxVolume: Float { get set }
  func play(effect: Effect)
}
