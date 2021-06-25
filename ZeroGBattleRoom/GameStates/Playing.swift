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
      return "Level_\(rawValue)"
    }
  }
  
  unowned let scene: GameScene
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    setupCamera()
    setupPhysics()
    setupLevel()
  }
  
  override func willExit(to nextState: GKState) {
    self.scene.entityManager.removeUIElements()
    NotificationCenter.default.post(name: .resizeView, object: -1000.0)
    
    self.scene.audioPlayer.pause(music: Audio.MusicFiles.level)
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }

  override func update(deltaTime seconds: TimeInterval) {
    self.repositionCamera()
  }
  
}

extension Playing {
  
  private func setupCamera() {
    scene.cam = SKCameraNode()
    scene.camera = scene.cam
    scene.addChild(scene.cam!)
  }
  
  private func setupPhysics() {
    scene.physicsBody = scene.borderBody
    scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    scene.physicsWorld.contactDelegate = scene
  }
  
  private func setupLevel() {
    scene.entityManager.spawnPanels()
  
    scene.entityManager.spawnResources()
    scene.entityManager.spawnHeros(mapSize: AppConstants.Layout.boundarySize)
    scene.entityManager.spawnDeposit()
    scene.entityManager.spawnField()
    
  
    scene.entityManager.addUIElements()
    
    scene.audioPlayer.play(effect: Audio.EffectFiles.startGame)
    scene.audioPlayer.play(music: Audio.MusicFiles.level)
  }

}

extension Playing {
  
  private func repositionCamera() {
    guard let camera = scene.cam else { return }
    guard let hero = scene.entityManager.hero as? General else { return }
    guard let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return }
    
    let sideEdge = AppConstants.Layout.mapSize.width / 2
    let frameSideEdge = scene.frame.size.width / 2
    if sideEdge - abs(spriteComponent.node.position.x) > frameSideEdge {
      camera.position.x = spriteComponent.node.position.x
    } else {
      let cameraPosX = sideEdge - frameSideEdge
      camera.position.x = spriteComponent.node.position.x < 0 ? -cameraPosX : cameraPosX
    }
    
    let topEdge = AppConstants.Layout.mapSize.height / 2
    let frameTopEdge = scene.frame.size.height / 2
    if topEdge - abs(spriteComponent.node.position.y) > frameTopEdge {
      camera.position.y = spriteComponent.node.position.y
    } else {
      let cameraPosY = topEdge - frameTopEdge
      camera.position.y = spriteComponent.node.position.y < 0 ? -cameraPosY : cameraPosY
    }
  }
  
}
