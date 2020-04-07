//
//  GameScene+TouchEvents.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
  func touchDown(atPoint pos : CGPoint) { }
  
  func touchMoved(toPoint pos : CGPoint) { }
    
  func touchUp(atPoint pos : CGPoint) {
    switch self.gameState.currentState {
    case is WaitingForTap:
//      NotificationCenter.default.post(name: .startMatchmaking, object: nil)
      self.gameState.enter(Playing.self)
    case is Playing:
      guard let hero = self.entityManager.hero as? General else { return }
      guard let spriteComponent = hero.component(ofType: SpriteComponent.self),
        let impulseComponent = hero.component(ofType: ImpulseComponent.self) else { return }
      
//      let hero = self.viewModel.hero
//
      guard self.viewModel.currentPlayerIndex != -1,
        !impulseComponent.isOnCooldown else { return }
      
      let tapVector = CGVector(dx: pos.x - spriteComponent.node.position.x,
                               dy: pos.y - spriteComponent.node.position.y)
      hero.impulse(vector: tapVector)
//      impulseComponent.isOnCooldown = true
      
      self.multiplayerNetworking.sendMove(start: spriteComponent.node.position,
                                          direction: tapVector)
      
      if let n = self.viewModel.spinnyNodeCopy {
        n.position = pos
        n.strokeColor = SKColor.red
        self.addChild(n)
      }
    case is GameOver:
      NotificationCenter.default.post(name: .restartGame, object: nil)
//      let newScene = GameScene(fileNamed: "GameScene")!
//      newScene.scaleMode = .aspectFill
//      let reveal = SKTransition.flipVertical(withDuration: 0.5)
//      self.view?.presentScene(newScene, transition: reveal)
    default: break
    }
    
  }
}
 
extension GameScene {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if let label = self.gameMessage, label.alpha == 1.0 {
//      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//    }
    
    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
}
