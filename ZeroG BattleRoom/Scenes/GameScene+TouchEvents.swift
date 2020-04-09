//
//  GameScene+TouchEvents.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

extension GameScene {
  func touchDown(atPoint pos : CGPoint) {
    self.lastTapDownPoint = pos
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    guard let hero = self.entityManager.hero as? General else { return }
    guard let spriteComponent = hero.component(ofType: SpriteComponent.self),
      let launchComponent = hero.component(ofType: LaunchComponent.self) else { return }
    
    let touchSlope = spriteComponent.node.position.slopeTo(point: self.lastTapDownPoint)
    let intersectingPoint = self.intersectingPoint(P1: self.lastTapDownPoint,
                                                   m1: touchSlope,
                                                   P2: pos,
                                                   m2: -1 / touchSlope)
    
    let spriteRotation = CGFloat.pi / 2 - spriteComponent.node.zRotation
    let directionVector = CGVector(dx: self.lastTapDownPoint.x - spriteComponent.node.position.x,
                                   dy: self.lastTapDownPoint.y - spriteComponent.node.position.y)
    let directionAngle = atan2(directionVector.dy, directionVector.dx) - spriteRotation
    let reversedVectorDirection = CGVector(dx: -directionVector.dx,
                                           dy: -directionVector.dy)
    let adjustmentVector = reversedVectorDirection.normalized() * AppConstants.Touch.maxSwipeDistance / 2
    let adjustmentPosition = CGPoint(x: intersectingPoint.x + adjustmentVector.dx,
                                     y: intersectingPoint.y + adjustmentVector.dy)
    
    let touchVector = CGVector(dx: adjustmentPosition.x - self.lastTapDownPoint.x,
                               dy: adjustmentPosition.y - self.lastTapDownPoint.y)
    let distance = min(AppConstants.Touch.maxSwipeDistance, touchVector.length())
    let percent = distance / 100
        
    let rotationVector = CGVector(dx: intersectingPoint.x - pos.x,
                                  dy: intersectingPoint.y - pos.y)
    let rotationAngle = atan2(rotationVector.dy, rotationVector.dx)// - spriteRotation
    
    let rotationDistatnce = min(AppConstants.Touch.maxRotation, rotationVector.length())
    let rotationPercent = rotationDistatnce / 100
    
    launchComponent.node.zRotation = directionAngle
    if let directionNode = launchComponent.node.childNode(withName: AppConstants.ComponentNames.directionNode),
      let angleNode = launchComponent.node.childNode(withName: AppConstants.ComponentNames.angleNode){
      
      directionNode.yScale = percent
      directionNode.position = CGPoint(x: 0.0, y: AppConstants.Touch.maxSwipeDistance * percent / 2)
      directionNode.alpha = percent
      
      angleNode.xScale = rotationPercent
      angleNode.position = CGPoint(x: AppConstants.Touch.maxRotation * rotationPercent / 4, y: 0.0)
      angleNode.position.x *= rotationAngle < 0 ? -1 : 1
      angleNode.alpha = rotationPercent
    }
  
//    if let n = self.viewModel.spinnyNodeCopy {
//      n.position = adjustmentPosition
//      n.strokeColor = SKColor.blue
//      self.addChild(n)
//    }
  }
    
  func touchUp(atPoint pos : CGPoint) {
    switch self.gameState.currentState {
    case is WaitingForTap:
//      NotificationCenter.default.post(name: .startMatchmaking, object: nil)
      self.gameState.enter(Playing.self)
    case is Playing:
      guard let hero = self.entityManager.hero as? General else { return }
      
      if case .beamed = hero.state {
        
      } else  {
        self.impulse(hero: hero, tapPosition: pos)
      }
      
      if let n = self.viewModel.spinnyNodeCopy {
        n.position = pos
        n.strokeColor = SKColor.red
        self.addChild(n)
      }
    case is GameOver:
      NotificationCenter.default.post(name: .restartGame, object: nil)
    default: break
    }
    
  }
  
  private func impulse(hero: General, tapPosition: CGPoint) {
    guard let spriteComponent = hero.component(ofType: SpriteComponent.self),
      let impulseComponent = hero.component(ofType: ImpulseComponent.self) else { return }
    
    guard self.viewModel.currentPlayerIndex != -1,
      !impulseComponent.isOnCooldown else { return }
    
    let tapVector = CGVector(dx: tapPosition.x - spriteComponent.node.position.x,
                             dy: tapPosition.y - spriteComponent.node.position.y)
    
    hero.impulse(vector: tapVector)
    impulseComponent.isOnCooldown = true
    
    self.multiplayerNetworking.sendMove(start: spriteComponent.node.position,
                                        direction: tapVector)
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

extension GameScene {
  func intersectingPoint(P1: CGPoint, m1: CGFloat, P2: CGPoint, m2: CGFloat) -> CGPoint {
    // Note: Point/slope form intersection equations
    //
    // Solve for x: m1(x - P1x) + P1y = m2(x - P2x) + P2y
    // m1(x - P1x) = m2(x - P2x) + P2y - P1y
    // m1(x) - m1(P1x) = m2(x) - m2(P2x) + P2y - P1y
    // m1(x) = m2(x) - m2(P2x) + P2y - P1y + m1(P1x)
    // m1(x) - m2(x) = -m2(P2x) + P2y - P1y + m1(P1x)
    // x(m1 - m2) = -m2(P2x) + P2y - P1y + m1(P1x)
    // x = (-m2(P2x) + P2y - P1y + m1(P1x)) / (m1 - m2)
    //
    // Solve for y: y = m(x - Px) + Py
    
    
    let x = (-1 * m2 * P2.x + P2.y - P1.y + m1 * P1.x) / (m1 - m2)
    let y = m1 * x - m1 * P1.x + P1.y
    return CGPoint(x: x, y: y)
  }
}

extension CGPoint {
  func slopeTo(point: CGPoint) -> CGFloat {
    // Note: Slope equation: m = (y - Py) / (x - Px)
    return (self.y - point.y) / (self.x - point.x)
  }
}
