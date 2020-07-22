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
  unowned let hero: General
  unowned let ghost: General
  unowned let sticker: SKSpriteNode
  
  var isShowingStep = false
  
  var currentStep: Tutorial.Step? = nil
  private var stepFinished = false {
    didSet {
      guard stepFinished,
        let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
      
      tapSpriteComponent.node.removeAllActions()
      
      self.stepFinished = false
    }
  }
  
  init(hero: General, ghost: General, sticker: SKSpriteNode) {
    self.hero = hero
    self.ghost = ghost
    self.sticker = sticker

    super.init()
    
    let tapComponent = SpriteComponent(texture: SKTexture(imageNamed: "tap"))
    tapComponent.node.position = Tutorial.Step.tapLaunch.tapPosition
    tapComponent.node.anchorPoint = CGPoint(x: 0.35, y: 0.9)
    tapComponent.node.zPosition = SpriteZPosition.menu.rawValue
    self.addComponent(tapComponent)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @discardableResult
  public func setupNextStep() -> Tutorial.Step? {
    self.isShowingStep = true
    
    if self.currentStep == nil {
      self.currentStep = .tapLaunch
    } else {
      self.currentStep = self.currentStep?.nextStep
    }
    
    if let currentStep = self.currentStep {
      self.setupTutorialAnimation()
      self.repositionSprites(pos: currentStep.startPosition,
                             rotation: currentStep.startRotation,
                             tapPos: currentStep.tapPosition)
    }
    
    return self.currentStep
  }
  
  private func hideTutorial() {
    guard let tapSpriteComponent = self.component(ofType: SpriteComponent.self),
      let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) else { return }

    tapSpriteComponent.node.alpha = 0.0
    ghostSpriteComponent.node.alpha = 0.0
    self.sticker.alpha = 0.0
  }

  private func showTutorial() {
    guard let tapSpriteComponent = self.component(ofType: SpriteComponent.self),
      let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) else { return }

    tapSpriteComponent.node.alpha = 1.0
    ghostSpriteComponent.node.alpha = 0.5
    self.sticker.alpha = 1.0
  }
}

extension TutorialAction {
  public func stopAllAnimations() {
    guard let tapSpriteComponent = self.component(ofType: SpriteComponent.self),
      let ghostSpriteComponent = self.ghost.component(ofType: SpriteComponent.self) else { return }
    
    tapSpriteComponent.node.removeAllActions()
    ghostSpriteComponent.node.removeAllActions()
    self.sticker.removeAllActions()
  
    self.hideTutorial()
  }
  
  public func setupTutorialAnimation() {
    guard let step = self.currentStep,
      let spriteComponent = self.ghost.component(ofType: SpriteComponent.self),
      let physicsComponent = self.ghost.component(ofType: PhysicsComponent.self),
      let launchComponent = self.ghost.component(ofType: LaunchComponent.self),
      let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
      
    self.stopAllAnimations()
    self.showTutorial()
    
    let prepareLaunch = SKAction.run {
      launchComponent.launchInfo.lastTouchBegan = step.tapPosition
      self.ghost.updateLaunchComponents(touchPosition: step.tapPosition)
      spriteComponent.node.alpha = 0.0
    }
    
    let launchGhost = SKAction.run {
      self.ghost.launch()
      ShapeFactory.shared.spawnSpinnyNodeAt(pos: step.tapPosition)
      spriteComponent.node.alpha = 0.5
    }
    
    let resetAction = SKAction.run {
      spriteComponent.node.position = step.startPosition
      spriteComponent.node.zRotation = 0.0
      tapSpriteComponent.node.position = step.tapPosition
      physicsComponent.physicsBody.velocity = .zero
      physicsComponent.physicsBody.angularVelocity = .zero
    }
    
    switch step {
    case .tapLaunch:
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 2.0),
        prepareLaunch,
        SKAction.wait(forDuration: 2.0),
        launchGhost,
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
      sticker.run(SKAction.fadeOut(withDuration: 0.0))
    case .pinchZoom:
      let zoomSteps = 30
      let zoomLevel: CGFloat = 1.5
      let zoomTimeInterval: TimeInterval = 0.05
      let pinchOutAction = SKAction.run {
        NotificationCenter.default.post(name: .resizeView, object: zoomLevel)
      }
      let pinchOutSequnce = SKAction.sequence([
        pinchOutAction,
        SKAction.wait(forDuration: zoomTimeInterval)])
      let pinchOut = SKAction.repeat(pinchOutSequnce, count: zoomSteps)
      
      let pinchInAction = SKAction.run {
        NotificationCenter.default.post(name: .resizeView, object: zoomLevel * -1.0)
      }
      let pinchInSequnce = SKAction.sequence([
        pinchInAction,
        SKAction.wait(forDuration: zoomTimeInterval)])
      let pinchIn = SKAction.repeat(pinchInSequnce, count: zoomSteps)
      
      let pinchSequence = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 4.0),
        pinchOut,
        SKAction.wait(forDuration: 2.0),
        pinchIn,
        SKAction.wait(forDuration: 3.0)]))
      
      let tapAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: 2.0),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.setTexture(SKTexture(imageNamed: "pinch-in")),
        SKAction.wait(forDuration: 3.5),
        SKAction.setTexture(SKTexture(imageNamed: "pinch-out")),
        SKAction.wait(forDuration: 2.0),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 2.0)]))
      
      let runGroup = SKAction.group([pinchSequence, tapAction])
      sticker.run(runGroup)
      tapSpriteComponent.node.run(SKAction.fadeOut(withDuration: 0.0))
    case .swipeLaunch:
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 2.0),
        prepareLaunch,
        SKAction.wait(forDuration: 3.5),
        launchGhost,
        SKAction.wait(forDuration: 4.0),
        resetAction]))
      
      let swipeAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: 2.0),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.move(by: CGVector(dx: 50.0, dy: -20.0), duration: 1.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 3.5)
      ]))
      
      let touchUpdateAction = SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.run {
          self.ghost.updateLaunchComponents(touchPosition: tapSpriteComponent.node.position)
        }])
      let touchAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 2.5),
        SKAction.repeat(touchUpdateAction, count: 15),
        SKAction.wait(forDuration: 5.5)
      ]))

      let runGroup = SKAction.group([launchSequence, swipeAction, touchAction])
      tapSpriteComponent.node.run(runGroup)
      sticker.run(SKAction.fadeOut(withDuration: 0.0))
    case .rotateThrow:
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 2.0),
        prepareLaunch,
        SKAction.wait(forDuration: 3.5),
        launchGhost,
        SKAction.wait(forDuration: 4.0),
        resetAction]))
      
      let swipeAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: 2.0),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.move(by: CGVector(dx: -50.0, dy: 0.0), duration: 1.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 3.5)
      ]))
    
      let touchUpdateAction = SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.run {
          self.ghost.updateLaunchComponents(touchPosition: tapSpriteComponent.node.position)
        }])
      let touchAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: 2.5),
        SKAction.repeat(touchUpdateAction, count: 15),
        SKAction.wait(forDuration: 5.5)
      ]))

      let runGroup = SKAction.group([launchSequence, swipeAction, touchAction])
      tapSpriteComponent.node.run(runGroup)
      sticker.run(SKAction.fadeOut(withDuration: 0.0))
    }
  }
  
  private func repositionSprites(pos: CGPoint, rotation: CGFloat, tapPos: CGPoint) {
    guard let heroSpriteComponent = self.hero.component(ofType: SpriteComponent.self),
      let spriteComponent = self.ghost.component(ofType: SpriteComponent.self),
      let tapSpriteComponent = self.component(ofType: SpriteComponent.self) else { return }
      
    DispatchQueue.main.async {
      tapSpriteComponent.node.position = tapPos
      spriteComponent.node.position = pos
      spriteComponent.node.zRotation = rotation
      heroSpriteComponent.node.position = pos
      heroSpriteComponent.node.zRotation = rotation
    }
  }
}
