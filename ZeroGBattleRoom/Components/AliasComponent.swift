//
//  NameComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class AliasComponent: GKComponent {
  let node: SKLabelNode
  
  private let labelPositionY: CGFloat = 40.0
  
  init(label: String = "Player") {
    self.node = SKLabelNode(fontNamed: "Arial")
    self.node.fontSize = 40
    self.node.fontColor = SKColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.2)
    self.node.position = CGPoint(x: 0.0, y: 0.0)
    self.node.text = label
//    self.node.name = AppConstants.ComponentNames.gameMessageName
      
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    guard let spriteComponent = self.entity?.component(ofType: SpriteComponent.self) else { return }
    
    let fullRotation = CGFloat.pi * 2
    self.node.zRotation = fullRotation - spriteComponent.node.zRotation
    
    // TODO: Calculate positon based on rotation and distance from node
//    if spriteComponent.node.zRotation < CGFloat.pi {
//      let percent = spriteComponent.node.zRotation * (self.labelPositionY * 2) / CGFloat.pi
//      self.node.position = CGPoint(x: self.node.position.x , y: percent - self.labelPositionY)
//    } else  {
//      let startingRadian = spriteComponent.node.zRotation - CGFloat.pi
//      let percent = startingRadian * (self.labelPositionY * 2) / CGFloat.pi
//      self.node.position = CGPoint(x: self.node.position.x , y: percent - self.labelPositionY)
//    }
  }
}
