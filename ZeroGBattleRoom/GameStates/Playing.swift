//
//  Playing.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/26/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit

class Playing: GKState {

  enum Level: Int {
    case level_1 = 1
    case level_2
    case level_3
    
    var filename: String {
      return "Level_\(self.rawValue)"
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
  
    self.scene.entityManager.spawnPanels()
    
//    self.loadLevel()
    
    self.scene.entityManager.spawnResources()
    self.scene.entityManager.spawnHeros(mapSize: AppConstants.Layout.boundarySize)
    self.scene.entityManager.spawnDeposit()

    let backButton = SKLabelNode(text: "Back")
    backButton.name = AppConstants.ButtonNames.backButtonName
    backButton.fontSize = 30.0
    backButton.position = CGPoint(x: backButton.frame.width / 2, y: -backButton.frame.height / 2)
    let newPosX = backButton.position.x + -UIScreen.main.bounds.width / 2 + 20.0
    let newPosY = backButton.position.y + UIScreen.main.bounds.height / 2 - 30.0
    backButton.position = CGPoint(x: newPosX, y: newPosY)
    backButton.zPosition = SpriteZPosition.menu.rawValue
    backButton.isUserInteractionEnabled = false

    self.scene.entityManager.addInGameUIView(element: backButton)
    
    self.scene.audioPlayer.play(effect: Audio.EffectFiles.startGame)
    self.scene.audioPlayer.play(music: Audio.MusicFiles.level)
  }
  
  override func willExit(to nextState: GKState) {
    self.scene.entityManager.removeInGameUIView()
    NotificationCenter.default.post(name: .resizeView, object: -1000.0)
    
    self.scene.audioPlayer.pause(music: Audio.MusicFiles.level)
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }

  override func update(deltaTime seconds: TimeInterval) {
    self.repositionCamera()
  }
  
  private func loadLevel(_ level: Level = .level_1) {
    guard let scene = SKScene(fileNamed: level.filename) else { return }
    
    scene.enumerateChildNodes(withName: AppConstants.ComponentNames.wallPanelName) { wallNode, _  in
//      if let wall = self.scene.entitityManager.wallNodeCopy {
//        wall.position = wallNode.position
//        wall.zRotation = wallNode.zRotation
//        self.scene.addChild(wall)
//      }
    }
  }
}

extension Playing {
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

extension Playing {
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
