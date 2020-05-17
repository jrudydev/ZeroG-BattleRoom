//
//  Tutorial.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit

class Tutorial: GKState {
  
  enum Step: Int {
    case tapLaunch = 1
//    case swipeLaunch
//    case rotateThrow
    
    var nextStep: Step? {
      switch self {
      case .tapLaunch: return nil // .swipeLaunch
//      case .swipeLaunch: return .rotateThrow
//      case .rotateThrow: return nil
      }
    }
  }
  
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    self.setupCamera()
    self.setupPhysics()
    
    let mapSize = AppConstants.Layout.mapSize
    let origin = CGPoint(x: -mapSize.width / 2, y: -mapSize.height / 2)
    let whiteBackground = SKShapeNode(rect: CGRect(origin: origin, size: mapSize))
    whiteBackground.fillColor = .white
    whiteBackground.zPosition = SpriteZPosition.background.rawValue
    self.scene.addChild(whiteBackground)
    
    let gridImage = SKSpriteNode(imageNamed: "tron_grid")
    gridImage.name = AppConstants.ComponentNames.gridImageName
    gridImage.aspectFillToSize(fillSize: mapSize)
    
    let widthDiff = (gridImage.size.width - UIScreen.main.bounds.width) / 2
    gridImage.position = CGPoint(x: gridImage.position.x +  widthDiff, y: gridImage.position.y)
    gridImage.zPosition = SpriteZPosition.simulation.rawValue
    
    self.scene.addChild(gridImage)
    
    self.scene.entityManager.spawnTutorialPanels()
    self.scene.entityManager.spawnHeros(mapSize: AppConstants.Layout.tutorialBoundrySize)
    
    let backButton = SKLabelNode(text: "Back")
    backButton.name = AppConstants.ComponentNames.backButtonName
    backButton.fontColor = .black
    backButton.fontSize = 30.0
    backButton.position = CGPoint(x: backButton.frame.width / 2, y: -backButton.frame.height / 2)
    let newPosX = backButton.position.x + -UIScreen.main.bounds.width / 2 + 20.0
    let newPosY = backButton.position.y + UIScreen.main.bounds.height / 2 - 30.0
    backButton.position = CGPoint(x: newPosX, y: newPosY)
    backButton.zPosition = SpriteZPosition.menu.rawValue
    backButton.isUserInteractionEnabled = false

    self.scene.entityManager.addInGameUIView(elements: [backButton])
    
    self.setupPlayers()
  }
  
  override func willExit(to nextState: GKState) { }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    self.repositionCamera()
  }

  private func loadLevel() {
    guard let scene = SKScene(fileNamed: "") else { return }
    
    scene.enumerateChildNodes(withName: AppConstants.ComponentNames.wallPanelName) { wallNode, _  in
//      if let wall = self.scene.entitityManager.wallNodeCopy {
//        wall.position = wallNode.position
//        wall.zRotation = wallNode.zRotation
//        self.scene.addChild(wall)
//      }
    }
  }
  
  private func setupPlayers() {
    for entity in self.scene.entityManager.playerEntites {
      guard let hero = entity as? General,
        let aliasComponent = hero.component(ofType: AliasComponent.self) else { continue }
      
      aliasComponent.node.text = ""
    }
    
    if let ghost = self.scene.entityManager.playerEntites[1] as? General,
      let ghostPhysicsComponent = ghost.component(ofType: PhysicsComponent.self) {
      
      ghostPhysicsComponent.physicsBody.collisionBitMask = PhysicsCategoryMask.package
      ghost.switchToState(.moving)
      self.scene.entityManager.setupTutorial(hero: ghost)
    }
  }
}

extension Tutorial {
  private func setupPhysics() {
    self.scene.physicsBody = self.scene.borderBody
    self.scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    self.scene.physicsWorld.contactDelegate = self.scene
  }
  
  private func setupCamera() {
    self.scene.cam = SKCameraNode()
    self.scene.camera = self.scene.cam
    self.scene.addChild(self.scene.cam!)
  }
}

extension Tutorial {
  private func repositionCamera() {
    guard let camera = self.scene.cam else { return }
    guard let hero = self.scene.entityManager.hero as? General else { return }
    guard let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return }
    
    let sideEdge = AppConstants.Layout.mapSize.width / 2
    let frameSideEdge = self.scene.frame.size.width / 2
    if sideEdge - abs(spriteComponent.node.position.x) > frameSideEdge {
      camera.position.x = spriteComponent.node.position.x
    } else {
      let cameraPosX = sideEdge - frameSideEdge
      camera.position.x = spriteComponent.node.position.x < 0 ? -cameraPosX : cameraPosX
    }
    
    let topEdge = AppConstants.Layout.mapSize.height / 2
    let frameTopEdge = self.scene.frame.size.height / 2
    if topEdge - abs(spriteComponent.node.position.y) > frameTopEdge {
      camera.position.y = spriteComponent.node.position.y
    } else {
      let cameraPosY = topEdge - frameTopEdge
      camera.position.y = spriteComponent.node.position.y < 0 ? -cameraPosY : cameraPosY
    }
  }
}
