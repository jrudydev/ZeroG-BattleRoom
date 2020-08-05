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


protocol TutorialActionDelegate: AnyObject {
  func setupHintAnimations(step: Tutorial.Step)
}
 

class TutorialAction: GKEntity {
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
  
  /// The delegate will send messages when the tutorial step should be animated or hidden
  weak var delegate: TutorialActionDelegate?
  
  init(delegate: TutorialActionDelegate? = nil) {
    self.delegate = delegate

    super.init()
    
    let tapComponent = SpriteComponent(texture: SKTexture(imageNamed: "tap"))
    tapComponent.node.name = AppConstants.ComponentNames.tutorialTapStickerName
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
      self.delegate?.setupHintAnimations(step: currentStep)
    }
    
    return self.currentStep
  }
}
