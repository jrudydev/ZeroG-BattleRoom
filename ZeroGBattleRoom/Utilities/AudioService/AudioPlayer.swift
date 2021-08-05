//
//  AudioPlayer.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import AVKit


class AudioPlayer {
  
  private var currentMusicPlayer: AVAudioPlayer?
  private var currentEffectPlayer: AVAudioPlayer?
  
  public init(music: Music? = nil) {
    if let music = music {
      // Preload music
      play(music: music)
      pause(music: music)
    }
  }
  
  var musicVolume: Float = 1.0 {
    didSet { currentMusicPlayer?.volume = musicVolume }
  }
  var sfxVolume: Float = 1.0 {
    didSet { currentEffectPlayer?.volume = sfxVolume }
  }
  
}

extension AudioPlayer: AudioPlayerProtocol {
  func play(music: Music) {
    currentMusicPlayer?.stop()
    guard let player = try? AVAudioPlayer(sound: music) else { return }
    
    player.volume = musicVolume
    player.numberOfLoops = -1
    player.play()
    
    currentMusicPlayer = player
  }
  
  func pause(music: Music) {
    currentMusicPlayer?.pause()
  }
  
  func play(effect: Effect) {
    guard let effectPlayer = try? AVAudioPlayer(sound: effect) else { return }
    effectPlayer.volume = sfxVolume
    effectPlayer.play()
    currentEffectPlayer = effectPlayer
  }
}
