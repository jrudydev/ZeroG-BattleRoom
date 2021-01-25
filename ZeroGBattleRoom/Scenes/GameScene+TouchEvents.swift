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
    
    let node = self.atPoint(pos)
    guard !self.isInGameButton(node: node) else { return }
    
    if self.gameState.currentState is Tutorial,
      let tutorialAction = self.entityManager.tutorialEntities.first as? TutorialAction,
      let tutorialStep = tutorialAction.currentStep,
      tutorialStep == .pinchZoom { return }
    
    self.hideTutorialIfNeeded(excludedSteps: [.pinchZoom])
    
    guard let hero = self.entityManager.hero as? General,
      let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
      let launchComponent = hero.component(ofType: LaunchComponent.self) else { return }

    guard self.numberOfTouches <= 1 else { launchComponent.hide(); return }
   
    let heroDistanceVector = heroSpriteComponent.node.position.vectorTo(point: pos)
    guard heroDistanceVector.length() > AppConstants.Touch.maxSwipeDistance else {
      launchComponent.hide()
      return
    }
  
    launchComponent.launchInfo.lastTouchBegan = pos
    hero.updateLaunchComponents(touchPosition: pos)
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    let node = self.atPoint(pos)
    guard !self.isInGameButton(node: node) else {
      if let hero = self.entityManager.hero as? General,
        let launchComponent = hero.component(ofType: LaunchComponent.self) {
        launchComponent.launchInfo.lastTouchBegan = nil
        launchComponent.hide()
      }
      
      return
    }
    
    switch self.gameState.currentState {
    case is Playing, is Tutorial:
      if let hero = self.entityManager.hero as? General {
        hero.updateLaunchComponents(touchPosition: pos)
      }
    default: break
    }
  }
    
  func touchUp(atPoint pos : CGPoint) {
    switch self.gameState.currentState {
    case is WaitingForTap:
      self.handleWaitingForTap(pos: pos)
    case is Tutorial, is Playing:
      let node = self.atPoint(pos)
      if self.isInGameButton(node: node) && node.alpha == 1.0 {
        self.handleThrowTap(node: node)
        self.handleBackTap(node: node)
        self.handleRestartTap(node: node)
      } else {
        self.handlePlayerLaunch(pos: pos)
      }
    case is GameOver:
      NotificationCenter.default.post(name: .restartGame, object: nil)
    default: break
    }
  }
  
  private func handleWaitingForTap(pos: CGPoint) {
    let node = self.atPoint(pos)
    if let name = node.name, name == AppConstants.ComponentNames.tutorialLabelName {
      self.gameState.enter(Tutorial.self)
    }
    if let name = node.name, name == AppConstants.ComponentNames.localLabelName {
      self.gameState.enter(MatchFound.self)
    }
    if let name = node.name, name == AppConstants.ComponentNames.onlineLabelName {
      NotificationCenter.default.post(name: .startMatchmaking, object: nil)
    }
  }
  
  private func handleThrowTap(node: SKNode) {
    if let name = node.name, name == AppConstants.ButtonNames.throwButtonName,
      let hero = self.entityManager.hero as? General,
      let spriteComponent = hero.component(ofType: SpriteComponent.self),
      let handsComponent = hero.component(ofType: HandsComponent.self),
      let throwButton = self.cam?.childNode(withName: AppConstants.ButtonNames.throwButtonName),
      throwButton.alpha == 1.0 {
      
      let throwPoint = self.convert(CGPoint(x: 0.0, y: 1.0), from: spriteComponent.node)
      hero.throwResourceAt(point: throwPoint)
      
      if !handsComponent.hasResourceInHand {
        throwButton.alpha = 0.5
      }
      
      self.audioPlayer.play(effect: Audio.EffectFiles.throwResource)
    }
  }
  
  private func handleBackTap(node: SKNode) {
    if let name = node.name, name == AppConstants.ButtonNames.backButtonName {
      self.matchEnded()
      NotificationCenter.default.post(name: .restartGame, object: nil)
      
      self.audioPlayer.play(effect: Audio.EffectFiles.uiMenuSelect)
    }
  }
  
  private func handleRestartTap(node: SKNode) {
    if let name = node.name,
      name == AppConstants.ButtonNames.refreshButtonName,
      self.gameState.currentState is Tutorial,
      let tutorialAction = self.entityManager.tutorialEntities.first as? TutorialAction,
      let tutorialStep = tutorialAction.currentStep {

      self.setupHintAnimations(step: tutorialStep)
      
//      self.audioPlayer.play(effect: Audio.EffectFiles.uiMenuSelect)
    }
  }
  
  private func isInGameButton(node: SKNode) -> Bool {
    guard let name = node.name else { return false }
    guard !AppConstants.ButtonNames.all.contains(name) else { return true}
    
    return false
  }
  
  private func handlePlayerLaunch(pos: CGPoint) {
    guard self.entityManager.currentPlayerIndex != -1,
      let hero = self.entityManager.hero as? General else { return }
    
    if case .beamed = hero.state {
      ShapeFactory.shared.removeAllSpinnyNodes()
      self.launch(hero: hero)
    }
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
//      if let index = self.entityManager.indexForWall(panel: vacatedPanel) {
//        self.multiplayerNetworking.sendWall(index: index, isOccupied: false)
//      }
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
      if self.gameState.currentState is Tutorial,
        let tutorialAction = self.entityManager.tutorialEntities.first as? TutorialAction,
        let tutorialStep = tutorialAction.currentStep {
        
        if tutorialStep == .pinchZoom {
          tutorialAction.setupNextStep()
        } else if tutorialStep == .tapLaunch {
          return
        }
      }
      
      switch self.gameState.currentState {
      case is Playing, is Tutorial:
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

    // Check if the hero did not launch
    if let hero = self.entityManager.hero as? General,
      let launchComponent = hero.component(ofType: LaunchComponent.self),
      launchComponent.launchInfo.lastTouchBegan == nil,
      hero.isBeamed {
      
      if let launchLineNode = launchComponent.node.childNode(withName: AppConstants.ComponentNames.launchLineName) as? SKShapeNode {
        launchLineNode.alpha = LaunchComponent.targetLineAlpha
      }
      
      if self.gameState.currentState is Tutorial,
        let beam = hero.occupiedPanel,
        let beamTeamComponent = beam.component(ofType: TeamComponent.self),
        beamTeamComponent.team == .team1 {
        
        self.showTutorialIfNeeded(excludedSteps: [.pinchZoom])
      }
    }
    
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
}

extension GameScene {
  
  private func hideTutorialIfNeeded(excludedSteps: [Tutorial.Step] = []) {
    guard gameState.currentState is Tutorial else { return }
    guard let tutorialStep = currentTutorialStep else { return }
    guard !excludedSteps.contains(tutorialStep) else { return }

    stopAllTutorialAnimations()
  }

  private func showTutorialIfNeeded(excludedSteps: [Tutorial.Step] = []) {
    guard gameState.currentState is Tutorial else { return }
    guard let tutorialStep = currentTutorialStep else { return }
    guard !excludedSteps.contains(tutorialStep) else { return }
    
    setupHintAnimations(step: tutorialStep)
  }
  
}
