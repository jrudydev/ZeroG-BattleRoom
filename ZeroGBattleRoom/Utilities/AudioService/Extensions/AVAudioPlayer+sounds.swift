//
//  AVAudio+sounds.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import AVKit

extension AVAudioPlayer {
  public enum PlayerError: Error {
    case fileNotFound
  }
  
  public convenience init(sound: SoundFile) throws {
    guard let url = Bundle.main.url(forResource: sound.name,
                                    withExtension: sound.ext)
      else { throw PlayerError.fileNotFound }
    
    try self.init(contentsOf: url)
  }
}
