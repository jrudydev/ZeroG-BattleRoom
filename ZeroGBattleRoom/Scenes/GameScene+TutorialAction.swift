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
  
  var tapSticker: SKNode? { childNode(withName: AppConstants.ComponentNames.tutorialTapStickerName) }
  var pinchSticker: SKNode? { cam?.childNode(withName: AppConstants.ComponentNames.tutorialPinchStickerName) }
  var throwSticker: SKNode? { cam?.childNode(withName: AppConstants.ComponentNames.tutorialThrowStickerName) }
  var throwButton: SKNode? { cam?.childNode(withName: AppConstants.ButtonNames.throwButtonName) }
  
  private func hideTutorialHints() {
    ghost?.sprite?.alpha = 0.0
    tapSticker?.alpha = 0.0
    pinchSticker?.alpha = 0.0
  }
  
  private func showTutorialHints() {
    tapSticker?.alpha = 1.0
    pinchSticker?.alpha = 1.0
  }
  
  func setupHintAnimations(step: Tutorial.Step) {
    guard let ghost = entityManager.playerEntites[1] as? General else { return }
  
    removeTutorialAnimations()
    positionTutorialElements(step: step)
    showTutorialHints()
    
    let initialWait = 1.0
    
    let prepareLaunch = SKAction.run {
      ghost.sprite?.alpha = 0.5
      ghost.launcher?.launchInfo.lastTouchBegan = step.tapPosition
      ghost.updateLaunchComponents(touchPosition: step.tapPosition)
    }

    let launchGhost = SKAction.run {
      ghost.launch()
    }

    let resetAction = SKAction.run {
      ghost.sprite?.alpha = 0.0
      ghost.sprite?.position = step.startPosition
      ghost.sprite?.zRotation = step.startRotation
      self.tapSticker?.position = step.tapPosition
      
      ghost.physics?.velocity = .zero
      ghost.physics?.angularVelocity = .zero
      
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
      tapSticker?.run(runGroup)
      pinchSticker?.run(SKAction.fadeOut(withDuration: 0.0))
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
      pinchSticker?.run(runGroup)
      tapSticker?.run(SKAction.fadeOut(withDuration: 0.0))
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
          guard let sticker = self.tapSticker else { return }
          
          ghost.updateLaunchComponents(touchPosition: sticker.position)
        }])
      let touchAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: initialWait + 0.5),
        SKAction.repeat(touchUpdateAction, count: 15),
        SKAction.wait(forDuration: 5.5)
      ]))

      let runGroup = SKAction.group([launchSequence, swipeAction, touchAction])
      tapSticker?.run(runGroup)
      pinchSticker?.run(SKAction.fadeOut(withDuration: 0.0))
    case .rotateThrow:
      let swipeFrames = 15, swipeFrameDuration = 0.1
      let moveDelta = CGPoint(x: -50.0, y: 0.0)
      let movePosition = CGPoint(x: step.tapPosition.x + moveDelta.x,
                                 y: step.tapPosition.y + moveDelta.y)
      
      let spawnSpinnyNode = SKAction.run {
        ShapeFactory.shared.spawnSpinnyNodeAt(pos: movePosition)
      }
      
      let throwResource = SKAction.run {
        guard let sprite = ghost.sprite else { return }
        
        let throwPoint = self.convert(Constants.heroThrowPoint, from: sprite)
        ghost.throwResourceAt(point: throwPoint)
      }
      
      let launchSequence = SKAction.repeatForever(SKAction.sequence([
        resetAction,
        SKAction.wait(forDuration: initialWait),
        prepareLaunch,
        SKAction.wait(forDuration: 3.5),
        launchGhost,
        spawnSpinnyNode,
        SKAction.wait(forDuration: 3.3),
        throwResource,
        SKAction.wait(forDuration: 0.5),
      ]))

      let swipeAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: initialWait),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.move(by: CGVector(dx: moveDelta.x, dy: moveDelta.y),
                      duration: Double(swipeFrames) * swipeFrameDuration),
        SKAction.wait(forDuration: 1.5),
        SKAction.fadeOut(withDuration: 0.5),
        SKAction.wait(forDuration: 3.3),
      ]))

      let touchUpdateAction = SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.run {
          guard let sticker = self.tapSticker else { return }
          
          ghost.updateLaunchComponents(touchPosition: sticker.position)
        }])
      let touchAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.wait(forDuration: initialWait + 0.5),
        SKAction.repeat(touchUpdateAction, count: swipeFrames),
        SKAction.wait(forDuration: 5.3)
      ]))
      
      let hintStickerAction = SKAction.repeatForever(SKAction.sequence([
        SKAction.fadeOut(withDuration: 0.0),
        SKAction.wait(forDuration: 7.4),
        SKAction.fadeIn(withDuration: 0.5),
        SKAction.wait(forDuration: 0.1),
      ]))

      tapSticker?.run(SKAction.group([launchSequence, swipeAction, touchAction]))
      pinchSticker?.run(SKAction.fadeOut(withDuration: 0.0))
      throwSticker?.run(hintStickerAction)
    }
  }
  
  func removeTutorialAnimations() {
    guard let tutorialStep = tutorialAction?.currentStep else { return }
    
    tapSticker?.removeAllActions()
    pinchSticker?.removeAllActions()
    throwSticker?.removeAllActions()
    ghost?.sprite?.removeAllActions()
    
    ghost?.physics?.collisionBitMask = 0
    ghost?.physics?.contactTestBitMask = 0
    entityManager.resourcesEntities[0].physics?.collisionBitMask = PhysicsCategoryMask.hero | PhysicsCategoryMask.wall
    entityManager.resourcesEntities[0].physics?.contactTestBitMask = PhysicsCategoryMask.hero | PhysicsCategoryMask.wall | PhysicsCategoryMask.deposit
  
    // Reposition the resource when needed
    if let package = hero?.hands?.leftHandSlot,
      let shapeComponent = package.component(ofType: ShapeComponent.self) {

      ghost?.hands?.release(resource: package)
      shapeComponent.node.removeFromParent()

      throwButton?.alpha = 0.5

      package.placeFor(tutorialStep: tutorialStep)
      scene?.addChild(shapeComponent.node)
    } else if let package = ghost?.hands?.leftHandSlot, let shape = package.shape {
      ghost?.hands?.release(resource: package)
      shape.removeFromParent()

      throwButton?.alpha = 0.5

      package.placeFor(tutorialStep: tutorialStep)
      scene?.addChild(shape)
    } else if entityManager.resourcesEntities.count > 0,
      let package = entityManager.resourcesEntities[0] as? Package {
      package.placeFor(tutorialStep: tutorialStep)
    }
    
    hideTutorialHints()
  }
  
  
  private func positionTutorialElements(step: Tutorial.Step) {
    guard let hero = hero,
          let ghost = ghost,
          let tapSticker = tapSticker else { return }
    
    ghost.physics?.collisionBitMask = PhysicsCategoryMask.package
    ghost.physics?.contactTestBitMask = PhysicsCategoryMask.package
    entityManager.resourcesEntities[0].physics?.collisionBitMask = PhysicsCategoryMask.ghost | PhysicsCategoryMask.hero | PhysicsCategoryMask.wall
    entityManager.resourcesEntities[0].physics?.contactTestBitMask = PhysicsCategoryMask.hero | PhysicsCategoryMask.wall

    DispatchQueue.main.async {
      tapSticker.position = step.tapPosition
      
      hero.sprite?.position = step.startPosition
      hero.sprite?.zRotation = step.startRotation
      
      ghost.sprite?.position = step.startPosition
      ghost.sprite?.zRotation = step.startRotation
      ghost.sprite?.physicsBody?.velocity = .zero
      ghost.sprite?.physicsBody?.angularVelocity = .zero
    }
  }
  
}
