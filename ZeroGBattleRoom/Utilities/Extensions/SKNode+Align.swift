//
//  SKNode+Align.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 7/23/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


public extension SKNode {
  func alignTopLeft() {
    position = CGPoint(x: frame.width / 2, y: -frame.height / 2)
    let newPosX = position.x + -UIScreen.main.bounds.width / 2 + 20.0
    let newPosY = position.y + UIScreen.main.bounds.height / 2 - 20.0
    position = CGPoint(x: newPosX, y: newPosY)
  }
  
  func alignTopRight() {
    position = CGPoint(x: frame.width / 2, y: -frame.height / 2)
    let newPosX = -position.x + UIScreen.main.bounds.width / 2 - 20.0
    let newPosY = position.y + UIScreen.main.bounds.height / 2 - 20.0
    position = CGPoint(x: newPosX, y: newPosY)
  }
  
  func alignMidLeft() {
    position = CGPoint(x: frame.width / 2, y: -frame.height / 2)
    let newPosX = position.x + -UIScreen.main.bounds.width / 2
    position = CGPoint(x: newPosX, y: position.y)
  }
  
  func alignMidRight() {
    position = CGPoint(x: frame.width / 2, y: -frame.height / 2)
    let newPosX = -position.x + UIScreen.main.bounds.width / 2
    position = CGPoint(x: newPosX, y: position.y)
  }
  
  func alignMidBottom() {
    let newPosY = position.y - UIScreen.main.bounds.height / 2 + 60.0
    position = CGPoint(x: position.x, y: newPosY)
  }
}
