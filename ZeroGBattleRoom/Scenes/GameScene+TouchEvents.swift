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
    self.numberOfTouches += 1
    
    guard let hero = self.entityManager.hero as? General,
      let launchComponent = hero.component(ofType: LaunchComponent.self) else { return }

    guard self.numberOfTouches <= 1 else {
      launchComponent.hide()
      return
    }
  
    launchComponent.launchInfo.lastTouchDown = pos
    self.updateLaunchComponents(pos: pos)
    
    if hero.isBeamed {
      launchComponent.showTargetLine()
    }
    
    ShapeFactory.shared.spawnSpinnyNodeAt(pos: pos)
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    switch self.gameState.currentState {
    case is Playing:
      self.updateLaunchComponents(pos: pos)
    default: break
    }
    
//    if let n = self.entityManager.spinnyNodeCopy {
//      n.position = pos
//      n.strokeColor = SKColor.blue
//      self.addChild(n)
//    }
  }
    
  func touchUp(atPoint pos : CGPoint) {
    switch self.gameState.currentState {
    case is WaitingForTap:
      self.handleWaitingForTap(pos: pos)
    case is Tutorial, is Playing:
      if let tutorialAction = self.entityManager.tutorialEntiies.first as? TutorialAction {
        tutorialAction.stopAllAnimations()
      }
      self.handleRestartTap(pos: pos)
      self.handlePlayerLaunch(pos: pos)
    case is GameOver:
      NotificationCenter.default.post(name: .restartGame, object: nil)
    default: break
    }
  }
  
  private func handleWaitingForTap(pos: CGPoint) {
    let touchedNode = self.atPoint(pos)
    if let name = touchedNode.name, name == AppConstants.ComponentNames.tutorialLabelName {
      self.gameState.enter(Tutorial.self)
    }
    if let name = touchedNode.name, name == AppConstants.ComponentNames.localLabelName {
      self.gameState.enter(Playing.self)
    }
    if let name = touchedNode.name, name == AppConstants.ComponentNames.onlineLabelName {
      NotificationCenter.default.post(name: .startMatchmaking, object: nil)
    }
  }
  
  private func handleRestartTap(pos: CGPoint) {
    let touchedNode = self.atPoint(pos)
    if let name = touchedNode.name, name == AppConstants.ComponentNames.backButtonName {
      self.matchEnded()
      NotificationCenter.default.post(name: .restartGame, object: nil)
      return
    }
  }
  
  private func handlePlayerLaunch(pos: CGPoint) {
    guard self.entityManager.currentPlayerIndex != -1,
      let hero = self.entityManager.hero as? General else { return }
    
    if case .beamed = hero.state {
      self.launch(hero: hero)
    } else  {
      if let impulseComponent = hero.component(ofType: ImpulseComponent.self),
        !impulseComponent.isOnCooldown {
        
        hero.impulseTo(location: pos) { sprite, velocity, angularVelocity in
          self.multiplayerNetworking.sendMove(start: sprite.position,
                                              rotation: sprite.zRotation,
                                              velocity: velocity,
                                              angularVelocity: angularVelocity,
                                              wasLaunch: false)
        }
      } else if let spriteComponent = hero.component(ofType: SpriteComponent.self) {
//        let throwPoint = self.convert(CGPoint(x: 0.0, y: 1.0), from: spriteComponent.node)
//        hero.throwResourceAt(point: throwPoint)
      }
    }
  }
  
  private func launch(hero: General) {
    guard let heroLaunchComponent = hero.component(ofType: LaunchComponent.self),
      heroLaunchComponent.launchInfo.lastTouchDown != nil else { return }
    
    hero.launch() { sprite, velocity, angularVelocity, vacatedPanel in
      self.multiplayerNetworking.sendMove(start: sprite.position,
                                          rotation: sprite.zRotation,
                                          velocity: velocity,
                                          angularVelocity: angularVelocity,
                                          wasLaunch: true)
      if let index = self.entityManager.indexForWall(panel: vacatedPanel) {
        self.multiplayerNetworking.sendWall(index: index, isOccupied: false)
      }
    }
  }
}
 
extension GameScene {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if let label = self.gameMessage, label.alpha == 1.0 {
//      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//    }
    self.lastPinchMagnitude = nil
    
    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touches.count == 2 {
      switch self.gameState.currentState {
      case is Playing:
        var touchesArray = [UITouch]()
        for (_, touch) in touches.enumerated() {
          touchesArray.append(touch)
        }
        let view = UIView(frame: UIScreen.main.bounds)
        let firstTouch = touchesArray[0].location(in: view)
        let secondTouch = touchesArray[1].location(in: view)
        
        let magnitude = sqrt(abs(secondTouch.x - firstTouch.x) + abs(secondTouch.y - firstTouch.y))
        
        if let pinchMagnitude = self.lastPinchMagnitude {
          let dt = pinchMagnitude - magnitude
          NotificationCenter.default.post(name: .resizeView, object: dt)
        } else {
          NotificationCenter.default.post(name: .resizeView, object: 0.0)
        }
        
        self.lastPinchMagnitude = magnitude
      default: break
      }
    }
    
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.numberOfTouches = 0
    
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
      let lastTouchDown = launchComponent.launchInfo.lastTouchDown else { return }
    
    let safeLastTouch = self.convert(lastTouchDown, to: spriteComponent.node)
    let safeMoveTouch = self.convert(pos, to: spriteComponent.node)
    
    let safePosition = self.safePosition(point: safeLastTouch, from: spriteComponent.node)
    let safeMovePosition = self.safePosition(point: safeMoveTouch, from: spriteComponent.node)
    let touchRotation = spriteComponent.node.fullRotationTo(point: safeLastTouch)
    let moveRotation = spriteComponent.node.fullRotationTo(point: safeMoveTouch)

    hero.updateLaunchComponents(position: safePosition,
                                movePosition: safeMovePosition,
                                rotation: touchRotation,
                                moveRotation: moveRotation)
    
//
//
//    guard let hero = self.entityManager.hero as? General,
//      let spriteComponent = hero.component(ofType: SpriteComponent.self),
//      let launchComponent = hero.component(ofType: LaunchComponent.self),
//      let physicsComponent = hero.component(ofType: PhysicsComponent.self),
//      let lastTouchDown = launchComponent.launchInfo.lastTouchDown,
//      (hero.isBeamed && !physicsComponent.isEffectedByPhysics) else { return }
//
//    var safeTouchPosition = self.convert(lastTouchDown, to: spriteComponent.node)
//    safeTouchPosition.y = abs(safeTouchPosition.y)
//    safeTouchPosition = self.convert(safeTouchPosition, from: spriteComponent.node)
//
//    var safeMovePosition = self.convert(pos, to: spriteComponent.node)
//    safeMovePosition.y = abs(safeMovePosition.y)
//    safeMovePosition = self.convert(safeMovePosition, from: spriteComponent.node)
//
//    let directionVector = spriteComponent.node.position.vectorTo(point: safeTouchPosition)
//    let directionRotation = directionVector.rotation - spriteComponent.node.zRotation
//
//    let moveVector = spriteComponent.node.position.vectorTo(point: safeMovePosition)
//    let moveRotation = moveVector.rotation - spriteComponent.node.zRotation
//
//    let localDirectionPosition = self.convert(lastTouchDown, to: spriteComponent.node)
//    let localMovePosition = self.convert(pos, to: spriteComponent.node)
//    let isDirectionNegitive = localDirectionPosition.y < 0
//    let isMovenNegitive = localMovePosition.y < 0
//    let directionFullRotation = self.fullRotation(rotation: directionRotation,
//                                                  isNegitive: isDirectionNegitive)
//    let moveFullRotation = self.fullRotation(rotation: moveRotation,
//                                                  isNegitive: isMovenNegitive)
//
//    let touchSlope = spriteComponent.node.position.slopeTo(point: safeTouchPosition)
//    let intersect = safeTouchPosition.intersection(m1: touchSlope,
//                                                   P2: safeMovePosition,
//                                                   m2: -1 / touchSlope)
//
//    let halfMaxSwipeDist = AppConstants.Touch.maxSwipeDistance / 2
//    let adjustmentVector = directionVector.reversed().normalized() * halfMaxSwipeDist
//    let adjustmentPosition = CGPoint(x: safeTouchPosition.x + adjustmentVector.dx,
//                                      y: safeTouchPosition.y + adjustmentVector.dy)
//
//    let launchVector = intersect.vectorTo(point: adjustmentPosition)
//    let rotationVector = safeMovePosition.vectorTo(point: intersect)
//
//
//    launchComponent.update(directionVector: directionVector,
//                           moveVector: launchVector,
//                           rotationVector: rotationVector,
//                           directionRotation: directionRotation,
//                           isLeftRotation: directionFullRotation > moveFullRotation)
    
//    if let n = self.entityManager.spinnyNodeCopy {
//      n.position = intersect
//      n.strokeColor = SKColor.green
//      self.addChild(n)
//    }
//
//    if let n = self.entityManager.spinnyNodeCopy {
//      n.position = adjustmentPosition
//      n.strokeColor = SKColor.yellow
//      self.addChild(n)
//    }
  }
  
  private func safePosition(point: CGPoint, from node: SKSpriteNode) -> CGPoint {
    return self.convert(CGPoint(x: point.x, y: abs(point.y)), from: node)
  }
}

extension CGFloat {
  func fullRotation(isNegitive: Bool) -> CGFloat {
    guard !isNegitive else {
      let multiplyer: CGFloat = self < 0.0 ? -1.0 : 1.0
      return (CGFloat.pi - abs(self)) * multiplyer
    }
    
    return self
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

extension SKSpriteNode {
  func fullRotationTo(point: CGPoint) -> CGFloat {
    let moveVector = self.position.vectorTo(point: point)
    let moveRotation = moveVector.rotation - self.zRotation
    let isMovenNegitive = point.y < 0
    
    return moveRotation.fullRotation(isNegitive: isMovenNegitive)
  }
}
