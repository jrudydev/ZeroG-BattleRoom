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
  let firstTapHand: SpriteComponent
  let secondTapHand: SpriteComponent
  
  unowned let ghost: General
  
  private var currentStep: Tutorial.Step? = nil
  private var stepFinished = false {
    didSet {
      guard stepFinished else { return }
      
      self.firstTapHand.node.removeAllActions()
      self.secondTapHand.node.removeAllActions()
      
      self.stepFinished = false
    }
  }
  
  init(hero: General) {
    self.firstTapHand = SpriteComponent(texture: SKTexture(imageNamed: "tap"))
    self.firstTapHand.node.anchorPoint = CGPoint(x: 0.3, y: 0.7)
    self.secondTapHand = SpriteComponent(texture: SKTexture(imageNamed: "block"))
    self.ghost = hero

    super.init()
    
    self.firstTapHand.node.zPosition = 100
    self.addComponent(self.firstTapHand)
    
    self.secondTapHand.node.alpha = 0.0
    self.secondTapHand.node.zPosition = 100
    self.addComponent(self.secondTapHand)
    
    self.setupNextStep()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupNextStep() {
    var thisStep: Tutorial.Step? = .tapLaunch
    if let currentStep = self.currentStep {
      thisStep = currentStep.nextStep
    }
    
    guard let nextStep = thisStep else { return }
    
    self.currentStep = nextStep
    
    switch self.currentStep {
    case .tapLaunch:
      guard let spriteComponent = self.ghost.component(ofType: SpriteComponent.self),
        let physicsComponent = self.ghost.component(ofType: PhysicsComponent.self) else { return }
      
      self.stopAllAnimations()
      self.showTutorial()
      
      let mapSize = AppConstants.Layout.tutorialBoundrySize
      let startPosY = -mapSize.height / 2 + AppConstants.Layout.wallSize.width / 4
      spriteComponent.node.position = CGPoint(x: 0.0, y: startPosY)
      
      let prepareAction = SKAction.run {
        self.ghost.updateLaunchComponents(position: .zero,
                                          movePosition: .zero,
                                          rotation: 0.0,
                                          moveRotation: 0.0)
      }
      
      let launchAction = SKAction.run {
        self.ghost.launch()
        
        ShapeFactory.shared.spawnSpinnyNodeAt(pos: .zero)
      }

      let resetAction = SKAction.run {
        spriteComponent.node.position = CGPoint(x: 0.0, y: startPosY)
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
      self.firstTapHand.node.run(runGroup)
    case .swipeLaunch: break
    case .rotateThrow: break
    default: break
    }
  }
  
  func stopAllAnimations() {
    self.firstTapHand.node.removeAllActions()
    self.secondTapHand.node.removeAllActions()
  
    self.hideTutorial()
  }
  
  private func hideTutorial() {
    self.firstTapHand.node.alpha = 0.0
    self.secondTapHand.node.alpha = 0.0
    if let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) {
      ghostSpriteComponent.node.alpha = 0.0
    }
  }
  
  private func showTutorial() {
    self.firstTapHand.node.alpha = 1.0
//    self.secondTapHand.node.alpha = 1.0
    if let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) {
      ghostSpriteComponent.node.alpha = 0.5
    }
  }
  
  
}
