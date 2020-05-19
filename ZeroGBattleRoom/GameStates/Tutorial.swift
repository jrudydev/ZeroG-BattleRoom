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
//    case swipeLaunch
//    case rotateThrow
    
    var nextStep: Step? {
      switch self {
      case .tapLaunch: return nil // .swipeLaunch
//      case .swipeLaunch: return .rotateThrow
//      case .rotateThrow: return nil
      }
    }
    
    var startPosition: CGPoint {
      guard self.rawValue < Tutorial.startingPoints.count else { return .zero }
      print(Tutorial.startingPoints)
      return Tutorial.startingPoints[self.index]
    }
    
    var tapPosition: CGPoint {
      guard self.rawValue < Tutorial.tapPoints.count else { return .zero }
    
      return Tutorial.tapPoints[self.index]
    }
    
    private var index: Int {
      return self.rawValue - 1
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
    
    let widthDiff = (gridImage.size.width - mapSize.width) / 2
    gridImage.position = CGPoint(x: gridImage.position.x +  widthDiff, y: gridImage.position.y)
    gridImage.zPosition = SpriteZPosition.simulation.rawValue
    
    self.scene.addChild(gridImage)
  
    self.scene.entityManager.loadTutorialLevel()
    self.scene.entityManager.spawnHeros(mapSize: AppConstants.Layout.tutorialBoundrySize)
    self.repositionHero()
    
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
    self.scene.entityManager.setupTutorial()
  }
  
  override func willExit(to nextState: GKState) { }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is GameOver.Type
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    self.repositionCamera()
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
  
  private func repositionHero(){
    guard let hero = self.scene.entityManager.playerEntites[0] as? General,
      let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.position = Tutorial.Step.tapLaunch.startPosition
  }
}
