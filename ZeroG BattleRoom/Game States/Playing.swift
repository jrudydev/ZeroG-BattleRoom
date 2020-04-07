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
  
  let wallNodeName = "wall"
  
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
  
    self.setupWalls()
//    self.setupTestWalls()
    
//    self.loadLevel()
    
//    self.spawnResources()
    if self.scene.viewModel.currentPlayerIndex == 0 {
      for _ in 0..<numberOfSpawnedResources {
        self.scene.entityManager.spawnResource()
      }
    }
    
    self.scene.entityManager.spawnHeros()
    self.scene.entityManager.spawnDeposit()
  }
  
  override func willExit(to nextState: GKState) { }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }

  override func update(deltaTime seconds: TimeInterval) {
    self.repositionCamera()
  }
  
  private func loadLevel(_ level: Level = .level_1) {
    guard let scene = SKScene(fileNamed: level.filename) else { return }
    
    scene.enumerateChildNodes(withName: "wall") { wallNode, _  in
      if let wall = self.scene.viewModel.wallNodeCopy {
        wall.position = wallNode.position
        wall.zRotation = wallNode.zRotation
        self.scene.addChild(wall)
      }
    }
  }
}

extension Playing {
  private func setupPhysics() {
    self.scene.physicsBody = self.scene.viewModel.borderBody
    self.scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    self.scene.physicsWorld.contactDelegate = self.scene
  }
  
  private func setupCamera() {
    self.scene.cam = SKCameraNode()
    self.scene.camera = self.scene.cam
    self.scene.addChild(self.scene.cam!)
  }
  
  private func setupTestWalls() {
    let bottomWallBlind = self.scene.getWallSegment(number: 8)
    for wall in bottomWallBlind {
      wall.position = CGPoint(x: wall.position.x,
                              y: -AppConstants.Layout.boundarySize.height)
      self.scene.addChild(wall)
    }
    
    let topWallBlind = self.scene.getWallSegment(number: 8)
    for wall in topWallBlind {
      wall.position = CGPoint(x: wall.position.x,
                              y: AppConstants.Layout.boundarySize.height)
      self.scene.addChild(wall)
    }
    
    let leftWallBlind = self.scene.getWallSegment(number: 8, orientation: .vertical)
    for wall in leftWallBlind {
      wall.position = CGPoint(x: -AppConstants.Layout.boundarySize.width,
                              y: wall.position.y)
      self.scene.addChild(wall)
    }
    
    let rightWallBlind = self.scene.getWallSegment(number: 8, orientation: .vertical)
    for wall in rightWallBlind {
      wall.position = CGPoint(x: AppConstants.Layout.boundarySize.width,
                              y: wall.position.y)
      self.scene.addChild(wall)
    }
  }
  
  private func setupWalls() {
    let wallThickness = AppConstants.Layout.wallSize.height
    
    let bottomWall = self.scene.getWallSegment(number: 10)
    for wall in bottomWall {
      wall.position = CGPoint(x: wall.position.x,
                              y: -AppConstants.Layout.boundarySize.height / 2)
      wall.config(.topBeamOnly)
      self.scene.addChild(wall)
    }
    
    let topWall = self.scene.getWallSegment(number: 10)
    for wall in topWall {
      wall.position = CGPoint(x: wall.position.x,
                              y: AppConstants.Layout.boundarySize.height / 2)
      self.scene.addChild(wall)
    }
    
    let verticlOrientation = GameSceneViewModel.WallOrientation.vertical
    let leftWall = self.scene.getWallSegment(number: 15,
                                             orientation: verticlOrientation)
    for wall in leftWall {
      let x = -AppConstants.Layout.boundarySize.width / 2 - wallThickness / 2
      wall.position = CGPoint(x: x, y: wall.position.y)
      self.scene.addChild(wall)
    }
    
    let rightWall = self.scene.getWallSegment(number: 15,
                                              orientation: verticlOrientation)
    for wall in rightWall {
      let x = AppConstants.Layout.boundarySize.width / 2 + wallThickness / 2
      wall.position = CGPoint(x: x, y: wall.position.y)
      self.scene.addChild(wall)
    }
    
    let bottomWallBlind = self.scene.getWallSegment(number: 5)
    for wall in bottomWallBlind {
      wall.position = CGPoint(x: wall.position.x,
                              y: -AppConstants.Layout.boundarySize.height * 0.30)
      self.scene.addChild(wall)
    }
    
    let topWallBlind = self.scene.getWallSegment(number: 5)
    for wall in topWallBlind {
      wall.position = CGPoint(x: wall.position.x,
                              y: AppConstants.Layout.boundarySize.height * 0.30)
      self.scene.addChild(wall)
    }
    
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: wall.frame.width * 0.4, y: -190.0)
      wall.zRotation = CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: -wall.frame.width * 0.4, y: -190.0)
      wall.zRotation = -CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: -wall.frame.width * 0.4, y: 190.0)
      wall.zRotation = CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: wall.frame.width * 0.4, y: 190.0)
      wall.zRotation = -CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: wall.frame.width * 1.1, y: -115.0)
      wall.zRotation = CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: -wall.frame.width * 1.1, y: -115.0)
      wall.zRotation = -CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: -wall.frame.width * 1.1, y: 115.0)
      wall.zRotation = CGFloat.pi / 4
      self.scene.addChild(wall)
    }
    if let wall = self.scene.viewModel.wallNodeCopy {
      wall.position = CGPoint(x: wall.frame.width * 1.1, y: 115.0)
      wall.zRotation = -CGFloat.pi / 4
      self.scene.addChild(wall)
    }
  }
  
  private func setupHeros() {
//    let heros = self.scene.viewModel.players
//    
//    if heros.count == 2 {
//      let firstHero = heros[0]
//      firstHero.position.y = -UIScreen.main.bounds.height/2
//      firstHero.zPosition = 10
//      firstHero.physicsBody?.collisionBitMask = PhysicsCategoryMask.package
//      firstHero.setupPhysicsBody()
//      self.scene.addChild(firstHero)
//      
//      let firstTrailNode = SKNode()
//      self.scene.addChild(firstTrailNode)
//      firstHero.setupTrail(node: firstTrailNode)
//      firstHero.setupAliasLabel()
//      
//      let secondHero = heros[1]
//      secondHero.position.y = UIScreen.main.bounds.height/2
//      secondHero.zRotation = CGFloat.pi
//      secondHero.zPosition = 10
//      secondHero.physicsBody?.collisionBitMask = PhysicsCategoryMask.package | PhysicsCategoryMask.hero
//      secondHero.setupPhysicsBody()
//      self.scene.addChild(secondHero)
//      
//      let secondTrailNode = SKNode()
//      self.scene.addChild(secondTrailNode)
//      secondHero.setupTrail(node: secondTrailNode)
//      secondHero.setupAliasLabel()
//    }
  }
  
  private func setupDepot() {
    let depot = self.scene.childNode(withName: "depot")
    depot?.physicsBody?.categoryBitMask = PhysicsCategoryMask.deposit
    depot?.physicsBody?.contactTestBitMask = PhysicsCategoryMask.hero
    depot?.physicsBody?.collisionBitMask = 0
  }
  
  private func spawnResources() {
//    let halfWidth = (AppConstants.Layout.boundarySize.width - 50) / 2
//    let halfHeight = (AppConstants.Layout.boundarySize.height - 50) / 2
//    
//    for resource in self.scene.viewModel.resources {
//      self.scene.addChild(resource)
//      print("I'm player \(self.scene.viewModel.currentPlayerIndex + 1), isPlayer1: \(self.scene.multiplayerNetworking.isPlayer1)")
//      if self.scene.viewModel.currentPlayerIndex == 0 {
//        resource.position = CGPoint(x: CGFloat.random(in: -halfWidth...halfWidth),
//                                    y: CGFloat.random(in: -halfHeight...halfHeight))
//        resource.randomImpulse()
//      }
//    }
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
    }
    
    let topEdge = AppConstants.Layout.mapSize.height / 2
    let frameTopEdge = self.scene.frame.size.height / 2
    if topEdge - abs(spriteComponent.node.position.y) > frameTopEdge {
      camera.position.y = spriteComponent.node.position.y
    }
  }
}
