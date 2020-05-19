//
//  TutorialAction.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/29/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
 

class TutorialAction: GKEntity {
  unowned let ghost: General
  
  private var currentStep: Tutorial.Step? = nil
  private var stepFinished = false {
    didSet {
      guard stepFinished,
        let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
      
      tapSpriteComponent.node.removeAllActions()
      
      self.stepFinished = false
    }
  }
  
  init(hero: General) {
    let tapComponent = SpriteComponent(texture: SKTexture(imageNamed: "tap"))
    tapComponent.node.position = Tutorial.Step.tapLaunch.tapPosition
    tapComponent.node.anchorPoint = CGPoint(x: 0.35, y: 0.9)
    
    self.ghost = hero

    super.init()
    
    tapComponent.node.zPosition = SpriteZPosition.menu.rawValue
    self.addComponent(tapComponent)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @discardableResult
  func setupNextStep() -> Tutorial.Step? {
    if self.currentStep == nil {
      self.currentStep = .tapLaunch
    } else {
      self.currentStep = self.currentStep?.nextStep
    }
    
    self.setupTutorialAnimation()
    
    return self.currentStep
  }
  
  func stopAllAnimations() {
    guard let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    tapSpriteComponent.node.removeAllActions()
  
    self.hideTutorial()
  }
  
  private func hideTutorial() {
    guard let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    tapSpriteComponent.node.alpha = 0.0
    if let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) {
      ghostSpriteComponent.node.alpha = 0.0
    }
  }
  
  private func showTutorial() {
    guard let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
    
    tapSpriteComponent.node.alpha = 1.0
    if let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) {
      ghostSpriteComponent.node.alpha = 0.5
    }
  }
  
  private func setupTutorialAnimation() {
    guard let step = self.currentStep,
      let spriteComponent = self.ghost.component(ofType: SpriteComponent.self),
      let physicsComponent = self.ghost.component(ofType: PhysicsComponent.self),
      let launchComponent = self.ghost.component(ofType: LaunchComponent.self),
      let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
      
    self.stopAllAnimations()
    self.showTutorial()
    
    let heroPosition = step.startPosition
    let tapPosition = step.tapPosition
    switch step {
    case .tapLaunch:
      tapSpriteComponent.node.position = tapPosition
      spriteComponent.node.position = heroPosition
      
      let prepareAction = SKAction.run {
        launchComponent.launchInfo.lastTouchBegan = tapPosition
        self.ghost.updateLaunchComponents(touchPosition: tapPosition)
      }
      
      let launchAction = SKAction.run {
        self.ghost.launch()
        
        ShapeFactory.shared.spawnSpinnyNodeAt(pos: tapPosition)
      }

      let resetAction = SKAction.run {
        spriteComponent.node.position = heroPosition
        spriteComponent.node.zRotation = 0.0
        physicsComponent.physicsBody.velocity = .zero
        physicsComponent.physicsBody.angularVelocity = .zero
      }
      
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 2.0),
        prepareAction,
        SKAction.wait(forDuration: 2.0),
        launchAction,
        SKAction.wait(forDuration: 4.0),
        resetAction]))
      
      let tapSequece = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: 2.0),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 3.5)]))
      
      let runGroup = SKAction.group([launchSequence, tapSequece])
      tapSpriteComponent.node.run(runGroup)
    default:
      break
    }
  }
}
