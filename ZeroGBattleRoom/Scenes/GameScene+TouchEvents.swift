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
  
  // MARK: Touch Down
  
  func touchDown(atPoint pos : CGPoint) {
    numberOfTouches += 1
    
    print("👇 Touch Down - Pos: \(pos)")

    guard !isInGameButton(node: atPoint(pos)) else { return }
    
    if gameState.currentState is Tutorial && !isPinchZoom(step: currentTutorialStep) { return }
    
    guard let hero = entityManager.hero as? General,
          let heroSprite = hero.sprite,
          let launchComponent = hero.component(ofType: LaunchComponent.self) else { return }
    guard case .beamed = hero.state else { return }
    guard numberOfTouches <= 1, maxSwipeDistance(tapPos: pos, heroPos: heroSprite.position) else {
        launchComponent.hide()
        return
      }
    
    print("👇🚀🕛 Launch components updated")
  
    launchComponent.launchInfo.lastTouchBegan = pos
    hero.updateLaunchComponents(touchPosition: pos)
  }
  
  private func isPinchZoom(step: Tutorial.Step?) -> Bool {
    guard let step = step else { return false }
    guard step != .pinchZoom else { return false }
    
    hideTutorialIfNeeded(excludedSteps: [.pinchZoom])
    
    return true
  }
  
  private func maxSwipeDistance(tapPos: CGPoint, heroPos: CGPoint) -> Bool {
    heroPos.vectorTo(point: tapPos).length() > AppConstants.Touch.maxSwipeDistance
  }
  
  // MARK: Touch Moved
  
  func touchMoved(toPoint pos : CGPoint) {
    guard let hero = entityManager.hero as? General,
          let launchComponent = hero.component(ofType: LaunchComponent.self) else { return }
    
    print("👉 Touch Moved - Pos: \(pos)")
    
    guard !isInGameButton(node: atPoint(pos)) else { launchComponent.hide(); return }
    
    switch gameState.currentState {
    case is Playing, is Tutorial:
      if let hero = entityManager.hero as? General {
        
        print("👉🚀🕛 Launch components updated")
        
        hero.updateLaunchComponents(touchPosition: pos)
      }
    default: break
    }
  }
  
  // MARK: Touch Up
    
  func touchUp(atPoint pos : CGPoint) {
    
    print("👆 Touch Up - Pos: \(pos)")
    
    let hero = entityManager.hero as? General
    let node = atPoint(pos)
    
    switch gameState.currentState {
    case is WaitingForTap:
      handleWaitingForTap(pos: pos)
    case is Tutorial, is Playing:
      if isInGameButton(node: node) && node.alpha == 1.0 {
        
        print("👆🆑 Button Tapped")
        
        handleThrowTap(node: node)
        handleBackTap(node: node)
        handleRestartTap(node: node)
      } else if let launchComponent = hero?.component(ofType: LaunchComponent.self),
         launchComponent.launchInfo.lastTouchBegan != nil {
        
        print("👆🚀 Player Luanched")
        
        handlePlayerLaunch(pos: pos)
      }
    case is GameOver:
      NotificationCenter.default.post(name: .restartGame, object: nil)
    default: break
    }
  }
  
  private func handleWaitingForTap(pos: CGPoint) {
    guard let name = atPoint(pos).name else { return }

    switch name {
    case AppConstants.ComponentNames.tutorialLabelName:
      gameState.enter(Tutorial.self)
    case AppConstants.ComponentNames.localLabelName:
      gameState.enter(MatchFound.self)
    case AppConstants.ComponentNames.onlineLabelName:
      NotificationCenter.default.post(name: .startMatchmaking, object: nil)
    default: break
    }
  }
  
  private func handleThrowTap(node: SKNode) {
    guard let name = node.name, name == AppConstants.ButtonNames.throwButtonName,
          let hero = entityManager.hero as? General,
          let spriteComponent = hero.component(ofType: SpriteComponent.self),
          let handsComponent = hero.component(ofType: HandsComponent.self),
          let throwButton = cam?.childNode(withName: AppConstants.ButtonNames.throwButtonName),
          throwButton.alpha == 1.0 else { return }
      
    let throwPoint = convert(CGPoint(x: 0.0, y: 1.0), from: spriteComponent.node)
    hero.throwResourceAt(point: throwPoint)
    
    throwButton.alpha = handsComponent.hasResourceInHand ? 1.0 : throwButton.alpha
    
    audioPlayer.play(effect: Audio.EffectFiles.throwResource)
  }
  
  private func handleBackTap(node: SKNode) {
    guard let name = node.name, name == AppConstants.ButtonNames.backButtonName else { return }
      
    matchEnded()
    NotificationCenter.default.post(name: .restartGame, object: nil)
    
    audioPlayer.play(effect: Audio.EffectFiles.uiMenuSelect)
  }
  
  private func handleRestartTap(node: SKNode) {
    guard let name = node.name, name == AppConstants.ButtonNames.refreshButtonName,
          let hero = entityManager.hero as? General,
          let heroSprite = hero.sprite else { return }
    
    if let tutorialStep = tutorialAction?.currentStep {
      setupHintAnimations(step: tutorialStep)
    } else {
      hero.impactedAt(point: heroSprite.position)
      heroSprite.position = CGPoint(x: 0.0, y: -AppConstants.Layout.boundarySize.height/2 + 20)
      heroSprite.zRotation = 0.0
    }
    
    audioPlayer.play(effect: Audio.EffectFiles.uiMenuSelect)
  }
  
  private func isInGameButton(node: SKNode) -> Bool {
    guard let name = node.name else { return false }
    guard !AppConstants.ButtonNames.all.contains(name) else { return true}
    
    return false
  }
  
  private func handlePlayerLaunch(pos: CGPoint) {
    guard entityManager.currentPlayerIndex != -1,
          let hero = entityManager.hero as? General,
          case .beamed = hero.state else { return }
    
    ShapeFactory.shared.removeAllSpinnyNodes()
    launch(hero: hero)
  }
  
  private func launch(hero: General) {
    guard let heroLaunchComponent = hero.component(ofType: LaunchComponent.self),
          heroLaunchComponent.launchInfo.lastTouchBegan != nil else { return }
    
    hero.launch() { sprite, velocity, angularVelocity, vacatedPanel in
      self.multiplayerNetworking.sendMove(start: sprite.position,
                                          rotation: sprite.zRotation,
                                          velocity: velocity,
                                          angularVelocity: angularVelocity,
                                          wasLaunch: true)
//      if let index = entityManager.indexForWall(panel: vacatedPanel) {
//        multiplayerNetworking.sendWall(index: index, isOccupied: false)
//      }
    }
  }
  
}
 
extension GameScene {
  
  // MARK: Touches Began
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if let label = gameMessage, label.alpha == 1.0 {
//      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//    }
    lastPinchMagnitude = nil
    
    for t in touches { touchDown(atPoint: t.location(in: self)) }
  }
  
  // MARK: TouchesMoved
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    defer { for t in touches { touchMoved(toPoint: t.location(in: self)) } }
    
    guard touches.count == 2 else { return }
    guard handleTutorialTouchMoved() else { return }
    
    switch gameState.currentState {
    case is Playing, is Tutorial:
      let touchesArray = Array(touches)
      handlePinchToZoom(touches: touchesArray)
    default: break
    }
  }
  
  private func handleTutorialTouchMoved() -> Bool {
    guard let tutorialStep = currentTutorialStep else { return true }
    guard tutorialStep != .tapLaunch else { return false }
    
    if tutorialStep == .pinchZoom {
      tutorialAction?.setupNextStep()
    }
    
    return true
  }
  
  private func handlePinchToZoom(touches: [UITouch]) {
    let view = UIView(frame: UIScreen.main.bounds)
    let firstTouch = touches[0].location(in: view)
    let secondTouch = touches[1].location(in: view)
    
    let magnitude = sqrt(abs(secondTouch.x - firstTouch.x) + abs(secondTouch.y - firstTouch.y))
    
    if let pinchMagnitude = lastPinchMagnitude {
      let dt = pinchMagnitude - magnitude
      NotificationCenter.default.post(name: .resizeView, object: dt)
    } else {
      NotificationCenter.default.post(name: .resizeView, object: 0.0)
    }
    
    lastPinchMagnitude = magnitude
  }
  
  // MARK: Touches Ended
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    numberOfTouches = 0

    handleHeroStillBeamed()
    
    for t in touches { touchUp(atPoint: t.location(in: self)) }
  }
  
  private func handleHeroStillBeamed() {
    guard let hero = entityManager.hero as? General,
          let launchComponent = hero.component(ofType: LaunchComponent.self),
          launchComponent.launchInfo.lastTouchBegan == nil,
          hero.isBeamed else { return }
      
      
    if let launchLineNode = launchComponent.node.childNode(withName: AppConstants.ComponentNames.launchLineName) as? SKShapeNode {
      launchLineNode.alpha = LaunchComponent.targetLineAlpha
    }
    
    if gameState.currentState is Tutorial,
      let beam = hero.occupiedPanel,
      let beamTeamComponent = beam.component(ofType: TeamComponent.self),
      beamTeamComponent.team == .team1 {
      
      showTutorialIfNeeded(excludedSteps: [.pinchZoom])
    }
  }
  
  // MARK: Touches Cancelled
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { touchUp(atPoint: t.location(in: self)) }
  }
  
}

extension GameScene {
  
  private func hideTutorialIfNeeded(excludedSteps: [Tutorial.Step] = []) {
    guard let tutorialStep = currentTutorialStep else { return }
    guard !excludedSteps.contains(tutorialStep) else { return }

    stopAllTutorialAnimations()
  }

  private func showTutorialIfNeeded(excludedSteps: [Tutorial.Step] = []) {
    guard let tutorialStep = currentTutorialStep else { return }
    guard !excludedSteps.contains(tutorialStep) else { return }
    
    setupHintAnimations(step: tutorialStep)
  }
  
}
