//
//  GameOver.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit

class GameOver: GKState {
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
//    let scale = SKAction.scale(to: 1.0, duration: 0.25)
//    scene.childNode(withName: GameMessageName)!.run(scale)
    
    //      let gameOver = self.childNode(withName: "Something") as! SKSpriteNode
    //      let textureName = self.gameWon ? "You Won" : "Game Over"
    //      let texture = SKTexture(imageNamed: textureName)
    //      let actionSequence = SKAction.sequence([
    //        SKAction.setTexture(texture),
    //        SKAction.scale(to: 1.0, duration: 0.25)])
    //
    //      gameOver.run(actionSequence)
  }
  
  override func willExit(to nextState: GKState) {
//    if nextState is Playing {
//      let scale = SKAction.scale(to: 0, duration: 0.4)
//      scene.childNode(withName: GameMessageName)!.run(scale)
//    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Playing.Type
  }

}
