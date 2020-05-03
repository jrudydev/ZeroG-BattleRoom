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
    self.createLongTermSpinnyNode()
  }
  
  private var spinnyNode : SKShapeNode?
  private var spinnyNodeCopy: SKShapeNode? {
    return self.spinnyNode?.copy() as? SKShapeNode
  }
  
  private var longTermSpinnyNode: SKSpriteNode?
  private var longTermSpinnyNodeCopy: SKShapeNode? {
    return self.spinnyNode?.copy() as? SKShapeNode
  }
  
  func spawnSpinnyNodeAt(pos: CGPoint, color: UIColor = .red, isLongTerm: Bool = false) {
    guard let gameScene = self.gameScene else { return }
    
    guard let spinnyNodeCopy = isLongTerm ? self.spinnyNodeCopy : self.longTermSpinnyNodeCopy else { return }
    
    spinnyNodeCopy.position = pos
    spinnyNodeCopy.strokeColor = color
    gameScene.addChild(spinnyNodeCopy)
  }
  
  func removeAllSpinnyNodes() {
    guard let gameScene = self.gameScene else { return }

    gameScene.enumerateChildNodes(withName: AppConstants.ComponentNames.spinnyNodeName) { node, _ in
      node.removeFromParent()
    }
  }
  
  private func createSpinnyNode() {
    let frame = UIScreen.main.bounds
    let width = (frame.size.width + frame.size.height) * 0.05
    self.spinnyNode = SKShapeNode(rectOf: CGSize(width: width, height: width),
                                  cornerRadius: width * 0.3)
    
    guard let spinnyNode = self.spinnyNode else { return }
    
    spinnyNode.lineWidth = 2.5
    
    spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
  }
  
  private func createLongTermSpinnyNode() {
    let frame = UIScreen.main.bounds
    let width = (frame.size.width + frame.size.height) * 0.05
    self.spinnyNode = SKShapeNode(rectOf: CGSize(width: width, height: width),
                                  cornerRadius: width * 0.3)
    
    guard let spinnyNode = self.spinnyNode else { return }
    
    spinnyNode.name = AppConstants.ComponentNames.spinnyNodeName
    spinnyNode.lineWidth = 2.5
    
    spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
  }
}
