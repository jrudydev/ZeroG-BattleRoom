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
    self.position = CGPoint(x: self.frame.width / 2, y: -self.frame.height / 2)
    let newPosX = self.position.x + -UIScreen.main.bounds.width / 2 + 20.0
    let newPosY = self.position.y + UIScreen.main.bounds.height / 2 - 30.0
    self.position = CGPoint(x: newPosX, y: newPosY)
  }
  
  func alignTopRight() {
    self.position = CGPoint(x: self.frame.width / 2, y: -self.frame.height / 2)
    let newPosX = -self.position.x + UIScreen.main.bounds.width / 2 - 20.0
    let newPosY = self.position.y + UIScreen.main.bounds.height / 2 - 30.0
    self.position = CGPoint(x: newPosX, y: newPosY)
  }
  
  func alignMidLeft() {
    self.position = CGPoint(x: self.frame.width / 2, y: -self.frame.height / 2)
    let newPosX = self.position.x + -UIScreen.main.bounds.width / 2 + 20.0
    let newPosY = self.position.y
    self.position = CGPoint(x: newPosX, y: newPosY)
  }
  
  func alignMidRight() {
    self.position = CGPoint(x: 100.0, y: 100.0)
//    self.position = CGPoint(x: self.frame.width / 2, y: -self.frame.height / 2)
//    let newPosX = -self.position.x + UIScreen.main.bounds.width / 2 - 20.0
//    self.position = CGPoint(x: newPosX, y: 250.0)
  }
  
  func alignMidBottom() {
    self.position = CGPoint(x: 0.0, y: -self.frame.height / 2 - 100.0)
  }
}
