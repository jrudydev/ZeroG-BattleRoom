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
    defer { self.numberOfTouches += 1 }
    
    guard let hero = self.entityManager.hero as? General,
      let launchComponent = hero.component(ofType: LaunchComponent.self) else { return }

    guard self.numberOfTouches <= 1 else {
      launchComponent.hide()
      return
    }
    
    launchComponent.launchInfo.lastTouchDown = pos
//    self.updateLaunchComponents(pos: pos)
    
    if let n = self.viewModel.spinnyNodeCopy {
      n.position = pos
      n.strokeColor = SKColor.red
      self.addChild(n)
    }
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    self.updateLaunchComponents(pos: pos)
    
//    if let n = self.viewModel.spinnyNodeCopy {
//      n.position = pos
//      n.strokeColor = SKColor.blue
//      self.addChild(n)
//    }
  }
    
  func touchUp(atPoint pos : CGPoint) {
    switch self.gameState.currentState {
    case is WaitingForTap:
      let touchedNode = self.atPoint(pos)
      if let name = touchedNode.name, name == AppConstants.ComponentNames.localLabelName {
        self.gameState.enter(Playing.self)
      }
      if let name = touchedNode.name, name == AppConstants.ComponentNames.onlineLabelName {
        NotificationCenter.default.post(name: .startMatchmaking, object: nil)
      }
    case is Playing:
      guard let hero = self.entityManager.hero as? General,
        self.viewModel.currentPlayerIndex != -1 else { return }
      
      if case .beamed = hero.state {
        hero.launch()
      } else  {
        hero.impulseTo(location: pos) { sprite, vector in
          self.multiplayerNetworking.sendMove(start: sprite.position, direction: vector)
        }
      }
      
      self.numberOfTouches -= 1
    case is GameOver:
      NotificationCenter.default.post(name: .restartGame, object: nil)
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

extension GameScene {
  private func updateLaunchComponents(pos: CGPoint) {
    guard let hero = self.entityManager.hero as? General,
      let spriteComponent = hero.component(ofType: SpriteComponent.self),
      let launchComponent = hero.component(ofType: LaunchComponent.self),
      let physicsComponent = hero.component(ofType: PhysicsComponent.self),
      let lastTouchDown = launchComponent.launchInfo.lastTouchDown,
      (hero.isBeamed && !physicsComponent.isEffectedByPhysics) else { return }
    
    var safeTouchPosition = self.convert(lastTouchDown, to: spriteComponent.node)
    safeTouchPosition.y = abs(safeTouchPosition.y)
    safeTouchPosition = self.convert(safeTouchPosition, from: spriteComponent.node)
    
    var safeMovePosition = self.convert(pos, to: spriteComponent.node)
    let isLeftRotation = safeMovePosition.x > 0
    safeMovePosition.y = abs(safeMovePosition.y)
    safeMovePosition = self.convert(safeMovePosition, from: spriteComponent.node)
    
    let directionVector = spriteComponent.node.position.vectorTo(point: safeTouchPosition)
    let directionRotation = directionVector.rotation - spriteComponent.node.zRotation
    
    let touchSlope = spriteComponent.node.position.slopeTo(point: safeTouchPosition)
    let intersect = safeTouchPosition.intersection(m1: touchSlope, P2: safeMovePosition,
                                                    m2: -1 / touchSlope)
    
    let halfMaxSwipeDist = AppConstants.Touch.maxSwipeDistance / 2
    let adjustmentVector = directionVector.reversed().normalized() * halfMaxSwipeDist
    let adjustmentPosition = CGPoint(x: safeTouchPosition.x + adjustmentVector.dx,
                                      y: safeTouchPosition.y + adjustmentVector.dy)
    
    let moveVector = intersect.vectorTo(point: adjustmentPosition)
    let rotationVector = safeMovePosition.vectorTo(point: intersect)
    
    
    launchComponent.update(directionVector: directionVector,
                           moveVector: moveVector,
                           rotationVector: rotationVector,
                           directionRotation: directionRotation,
                           isLeftRotation: isLeftRotation)
    
//    if let n = self.viewModel.spinnyNodeCopy {
//      n.position = intersect
//      n.strokeColor = SKColor.green
//      self.addChild(n)
//    }
//
//    if let n = self.viewModel.spinnyNodeCopy {
//      n.position = adjustmentPosition
//      n.strokeColor = SKColor.yellow
//      self.addChild(n)
//    }
  }
}

extension CGPoint {
  func vectorTo(point: CGPoint) -> CGVector {
    return CGVector(dx: point.x - self.x, dy: point.y - self.y)
  }
  
  func intersection(m1: CGFloat, P2: CGPoint, m2: CGFloat) -> CGPoint {
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
    
    
    let x = (-1 * m2 * P2.x + P2.y - self.y + m1 * self.x) / (m1 - m2)
    let y = m1 * x - m1 * self.x + self.y
    return CGPoint(x: x, y: y)
  }
  
  func slopeTo(point: CGPoint) -> CGFloat {
    // Note: Slope equation: m = (y - Py) / (x - Px)
    return (self.y - point.y) / (self.x - point.x)
  }
}
