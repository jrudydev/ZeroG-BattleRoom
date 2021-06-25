//
//  GameScene+Tutorial.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene: TutorialActionDelegate {
  
  private func hideTutorialHints() {
    guard let ghost = entityManager.playerEntites[1] as? General,
      let ghostSpriteComponent = ghost.component(ofType: SpriteComponent.self),
      let tapSticker = childNode(withName: AppConstants.ComponentNames.tutorialTapStickerName),
      let pinchSticker = cam?.childNode(withName: AppConstants.ComponentNames.tutorialPinchStickerName) else { return }

    ghostSpriteComponent.node.alpha = 0.0
    tapSticker.alpha = 0.0
    pinchSticker.alpha = 0.0
  }
  
  private func showTutorialHints() {
    guard let tapSticker = childNode(withName: AppConstants.ComponentNames.tutorialTapStickerName),
      let pinchSticker = cam?.childNode(withName: AppConstants.ComponentNames.tutorialPinchStickerName)
      else { return }

    tapSticker.alpha = 1.0
    pinchSticker.alpha = 1.0
  }
  
  func setupHintAnimations(step: Tutorial.Step) {
    guard let ghost = entityManager.playerEntites[1] as? General,
      let ghostSpriteComponent = ghost.component(ofType: SpriteComponent.self),
      let ghostHandsComponent = ghost.component(ofType: HandsComponent.self),
      let ghostPhysicsComponent = ghost.component(ofType: PhysicsComponent.self),
      let launchComponent = ghost.component(ofType: LaunchComponent.self),
      let tapSticker = childNode(withName: AppConstants.ComponentNames.tutorialTapStickerName),
      let pinchSticker = cam?.childNode(withName: AppConstants.ComponentNames.tutorialPinchStickerName),
      let throwHintSticker = cam?.childNode(withName: AppConstants.ComponentNames.tutorialThrowStickerName) else { return }
  
    stopAllTutorialAnimations()
    resetSprites(pos: step.startPosition, rotation: step.startRotation, tapPos: step.tapPosition)
    showTutorialHints()
    
    let initialWait = 1.0
    
    let prepareLaunch = SKAction.run {
      ghostSpriteComponent.node.alpha = 0.5
      launchComponent.launchInfo.lastTouchBegan = step.tapPosition
      ghost.updateLaunchComponents(touchPosition: step.tapPosition)
    }

    let launchGhost = SKAction.run {
      ghost.launch()
    }

    let resetAction = SKAction.run {
      ghostSpriteComponent.node.alpha = 0.0
      ghostSpriteComponent.node.position = step.startPosition
      ghostSpriteComponent.node.zRotation = step.startRotation
      tapSticker.position = step.tapPosition
      ghostPhysicsComponent.physicsBody.velocity = .zero
      ghostPhysicsComponent.physicsBody.angularVelocity = .zero
      
      if self.entityManager.resourcesEntities.count > 0,
         let package = self.entityManager.resourcesEntities[0] as? Package {
        package.placeFor(tutorialStep: step)
      }
    }

    switch step {
    case .tapLaunch:
      let spawnSpinnyNode = SKAction.run {
        ShapeFactory.shared.spawnSpinnyNodeAt(pos: step.tapPosition)
      }
      
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        resetAction,
        SKAction.wait(forDuration: initialWait),
        prepareLaunch,
        SKAction.wait(forDuration: 2.0),
        launchGhost,
        spawnSpinnyNode,
        SKAction.wait(forDuration: 3.25)
      ]))

      let tapSequece = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: initialWait),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 2.75)]))

      let runGroup = SKAction.group([launchSequence, tapSequece])
      tapSticker.run(runGroup)
      pinchSticker.run(SKAction.fadeOut(withDuration: 0.0))
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
        SKAction.wait(forDuration: initialWait + 2.0),
        pinchOut,
        SKAction.wait(forDuration: 2.0),
        pinchIn,
        SKAction.wait(forDuration: 2.0)]))

      let tapAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: initialWait),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.setTexture(SKTexture(imageNamed: "pinch-in")),
        SKAction.wait(forDuration: 3.5),
        SKAction.setTexture(SKTexture(imageNamed: "pinch-out")),
        SKAction.wait(forDuration: 2.0),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 1.0)]))

      let runGroup = SKAction.group([pinchSequence, tapAction])
      pinchSticker.run(runGroup)
      tapSticker.run(SKAction.fadeOut(withDuration: 0.0))
    case .swipeLaunch:
      let xMoveDelta: CGFloat = 50.0
      let yMoveDelta: CGFloat = -20.0
      let movePosition = CGPoint(x: step.tapPosition.x + xMoveDelta,
                                 y: step.tapPosition.y + yMoveDelta)
      
      let spawnSpinnyNode = SKAction.run {
        ShapeFactory.shared.spawnSpinnyNodeAt(pos: movePosition)
      }
      
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        resetAction,
        SKAction.wait(forDuration: initialWait),
        prepareLaunch,
        SKAction.wait(forDuration: 3.5),
        launchGhost,
        spawnSpinnyNode,
        SKAction.wait(forDuration: 2.5),
      ]))

      let swipeAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: initialWait),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.move(by: CGVector(dx: xMoveDelta, dy: yMoveDelta), duration: 1.5),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 2.0)
      ]))

      let touchUpdateAction = SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.run {
          ghost.updateLaunchComponents(touchPosition: tapSticker.position)
        }])
      let touchAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: initialWait + 0.5),
        SKAction.repeat(touchUpdateAction, count: 15),
        SKAction.wait(forDuration: 5.5)
      ]))

      let runGroup = SKAction.group([launchSequence, swipeAction, touchAction])
      tapSticker.run(runGroup)
      pinchSticker.run(SKAction.fadeOut(withDuration: 0.0))
    case .rotateThrow:
      let swipeFrames = 15, swipeFrameDuration = 0.1
      let moveDelta = CGPoint(x: -50.0, y: 0.0)
      let movePosition = CGPoint(x: step.tapPosition.x + moveDelta.x,
                                 y: step.tapPosition.y + moveDelta.y)
      
      let spawnSpinnyNode = SKAction.run {
        ShapeFactory.shared.spawnSpinnyNodeAt(pos: movePosition)
      }
      
      let throwResource = SKAction.run {
        let throwPoint = self.convert(CGPoint(x: 0.0, y: 1.0), from: ghostSpriteComponent.node)
        ghost.throwResourceAt(point: throwPoint)
      }
      
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        resetAction,
        SKAction.wait(forDuration: initialWait),
        prepareLaunch,
        SKAction.wait(forDuration: 3.5),
        launchGhost,
        spawnSpinnyNode,
        SKAction.wait(forDuration: 3.4),
        throwResource,
        SKAction.wait(forDuration: 2.6),
      ]))

      let swipeAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: initialWait),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.move(by: CGVector(dx: moveDelta.x, dy: moveDelta.y),
                      duration: Double(swipeFrames) * swipeFrameDuration),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 3.5),
        SKAction.wait(forDuration: 2.0)
      ]))

      let touchUpdateAction = SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.run {
          ghost.updateLaunchComponents(touchPosition: tapSticker.position)
        }])
      let touchAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: initialWait + 0.5),
        SKAction.repeat(touchUpdateAction, count: swipeFrames),
        SKAction.wait(forDuration: 7.5)
      ]))
      
      let hintStickerAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: 7.4),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 0.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 1.6)
      ]))

      tapSticker.run(SKAction.group([launchSequence, swipeAction, touchAction]))
      pinchSticker.run(SKAction.fadeOut(withDuration: 0.0))
      throwHintSticker.run(hintStickerAction)
    }
  }
  
  func stopAllTutorialAnimations() {
    guard let hero = entityManager.hero as? General,
      let ghost = entityManager.playerEntites[1] as? General,
      let ghostSpriteComponent = ghost.component(ofType: SpriteComponent.self),
      let ghostHandsComponent = ghost.component(ofType: HandsComponent.self),
//      let ghostPhysicsComponent = ghost.component(ofType: PhysicsComponent.self),
      let tapSticker = childNode(withName: AppConstants.ComponentNames.tutorialTapStickerName),
      let pinchSticker = cam?.childNode(withName: AppConstants.ComponentNames.tutorialPinchStickerName),
      let throwButton = cam?.childNode(withName: AppConstants.ButtonNames.throwButtonName),
      let throwHintSticker = cam?.childNode(withName: AppConstants.ComponentNames.tutorialThrowStickerName),
      let tutorialStep = tutorialAction?.currentStep else { return }
    
    tapSticker.removeAllActions()
    ghostSpriteComponent.node.removeAllActions()
    pinchSticker.removeAllActions()
    throwHintSticker.removeAllActions()

//    // Reposition the resource when needed
//    if let package = ghostHandsComponent.leftHandSlot,
//      let shapeComponent = package.component(ofType: ShapeComponent.self) {
//
//      ghostHandsComponent.release(resource: package)
//      shapeComponent.node.removeFromParent()
//
//      throwButton.alpha = 0.5
//
//      package.placeFor(tutorialStep: tutorialStep)
//      scene?.addChild(shapeComponent.node)
//    } else if entityManager.resourcesEntities.count > 0,
//      let package = entityManager.resourcesEntities[0] as? Package {
//      package.placeFor(tutorialStep: tutorialStep)
//    }
    
    hideTutorialHints()
  }
  
  private func resetSprites(pos: CGPoint, rotation: CGFloat, tapPos: CGPoint) {
    guard let hero = entityManager.hero as? General,
      let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
      let ghost = entityManager.playerEntites[1] as? General,
      let ghostSpriteComponent = ghost.component(ofType: SpriteComponent.self),
      let tapSticker = childNode(withName: AppConstants.ComponentNames.tutorialTapStickerName) else { return }

    DispatchQueue.main.async {
      tapSticker.position = tapPos
      
      heroSpriteComponent.node.position = pos
      heroSpriteComponent.node.zRotation = rotation
      
      ghostSpriteComponent.node.position = pos
      ghostSpriteComponent.node.zRotation = rotation
      ghostSpriteComponent.node.physicsBody?.velocity = .zero
      ghostSpriteComponent.node.physicsBody?.angularVelocity = .zero
    }
  }
  
}
