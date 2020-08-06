//
//  SoundFileProtocol.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation


public protocol SoundFile {
  var name: String { get }
  var ext: String { get }
}
