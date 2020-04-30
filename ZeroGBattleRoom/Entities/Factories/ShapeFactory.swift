//
//  ShapeFactory.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/30/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


class ShapeFactory {
  
  static var shared = ShapeFactory()
  
  unowned var gameScene: GameScene?
  
  private init() {
    self.createSpinnyNode()
  }
  
  private var spinnyNode : SKShapeNode?
  private var spinnyNodeCopy: SKShapeNode? {
    return self.spinnyNode?.copy() as? SKShapeNode
  }
  
  func spawnSpinnyNodeAt(pos: CGPoint, color: UIColor = .red) {
    guard let gameScene = self.gameScene,
      let spinnyNodeCopy = self.spinnyNodeCopy else { return }
    
    spinnyNodeCopy.position = pos
    spinnyNodeCopy.strokeColor = color
    gameScene.addChild(spinnyNodeCopy)
  }
  
  private func createSpinnyNode() {
    let frame = UIScreen.main.bounds
    let width = (frame.size.width + frame.size.height) * 0.05
    self.spinnyNode = SKShapeNode(rectOf: CGSize(width: width, height: width),
                                  cornerRadius: width * 0.3)
    
    
    guard let spinnyNode = self.spinnyNode else { return }
    
    spinnyNode.lineWidth = 2.5
    
    spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
    spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                      SKAction.fadeOut(withDuration: 0.5),
                                      SKAction.removeFromParent()]))
  }
  
}
