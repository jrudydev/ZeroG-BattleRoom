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
  
  static let teamUserDataKey = "team"
  static let stepUserDataKey = "step"
  static let beamsUserDataKey = "beams"
  
  enum Step: Int {
    case tapLaunch = 1
    case pinchZoom
    case swipeLaunch
    case rotateThrow
    
    var nextStep: Step? {
      switch self {
      case .tapLaunch: return .pinchZoom
      case .pinchZoom: return .swipeLaunch
      case .swipeLaunch: return .rotateThrow
      case .rotateThrow: return nil
      }
    }
    
    var startPosition: CGPoint {
      guard index <= Tutorial.startingPoints.count else { return .zero }
      
      return Tutorial.startingPoints[index]
    }
    
    var startRotation: CGFloat {
      switch self {
      case .pinchZoom, .swipeLaunch: return -1.6
      case .rotateThrow: return 3.14
      default: return 0.0
      }
    }
    
    var tapPosition: CGPoint {
      guard index <= Tutorial.startingPoints.count else { return .zero }
    
      return Tutorial.tapPoints[index]
    }
    
    var midPosition: CGPoint {
      guard index <= Tutorial.startingPoints.count else { return .zero }
      
      let diffPoint = CGPoint(x: startPosition.x - tapPosition.x,
                              y: startPosition.y - tapPosition.y)
      return CGPoint(x: tapPosition.x + diffPoint.x/2,
                     y: tapPosition.y + diffPoint.y/2)
    }
    
    private var index: Int {
      return rawValue - 1
    }
  }
  
  unowned let scene: GameScene
  
  static var startingPoints: [CGPoint] = {
    guard let scene = SKScene(fileNamed: "TutorialScene") else { return [] }
    
    var points = [SKNode]()
    scene.enumerateChildNodes(withName: AppConstants.ComponentNames.tutorialStartPointName) {
      startNode, _  in
      
      points.append(startNode)
    }
    return points.sorted { n1, n2 in
      let n1StepValue = n1.userData![stepUserDataKey] as! Int
      let n2StepValue = n2.userData![stepUserDataKey] as! Int

      return n1StepValue < n2StepValue
    }.map { $0.position }
  }()
  
  static var tapPoints: [CGPoint] = {
    guard let scene = SKScene(fileNamed: "TutorialScene") else { return [] }
    
    var points = [SKNode]()
    scene.enumerateChildNodes(withName: AppConstants.ComponentNames.tutorialTapPointName) {
      startNode, _  in
      
      points.append(startNode)
    }
    return points.sorted { n1, n2 in
      let n1StepValue = n1.userData![stepUserDataKey] as! Int
      let n2StepValue = n2.userData![stepUserDataKey] as! Int

      return n1StepValue < n2StepValue
    }.map { $0.position }
  }()
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    setupCamera()
    setupPhysics()
    
    let mapSize = AppConstants.Layout.mapSize
    let origin = CGPoint(x: -mapSize.width / 2, y: -mapSize.height / 2)
    let whiteBackground = SKShapeNode(rect: CGRect(origin: origin, size: mapSize))
    whiteBackground.fillColor = .white
    whiteBackground.zPosition = SpriteZPosition.background.rawValue
    scene.addChild(whiteBackground)
    
    let gridImage = SKSpriteNode(imageNamed: "tron_grid")
    gridImage.name = AppConstants.ComponentNames.gridImageName
    gridImage.aspectFillToSize(fillSize: mapSize)
    
    let widthDiff = (gridImage.size.width - mapSize.width) / 2
    gridImage.position = CGPoint(x: gridImage.position.x +  widthDiff, y: gridImage.position.y)
    gridImage.zPosition = SpriteZPosition.simulation.rawValue
    
    scene.addChild(gridImage)
  
    scene.entityManager.loadTutorialLevel()
    scene.entityManager.addUIElements()
    
    scene.entityManager.spawnHeros(mapSize: AppConstants.Layout.tutorialBoundrySize)
    scene.entityManager.spawnDeposit()
    
    scene.entityManager.setupTutorial()
    
    scene.audioPlayer.play(music: Audio.MusicFiles.level)
  }
  
  override func willExit(to nextState: GKState) {
    scene.audioPlayer.pause(music: Audio.MusicFiles.level)
    NotificationCenter.default.post(name: .resizeView, object: -1000.0)
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    repositionCamera()
  }
  
}

extension Tutorial {
  
  private func setupPhysics() {
    scene.physicsBody = scene.borderBody
    scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    scene.physicsWorld.contactDelegate = scene
  }
  
  private func setupCamera() {
    scene.cam = SKCameraNode()
    scene.camera = scene.cam
    scene.addChild(scene.cam!)
  }
  
}

extension Tutorial {
  
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
