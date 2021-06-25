//
//  EntityManager.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


let numberOfSpawnedResources = 10
let resourcesNeededToWin = 3
let minDriftVelocity: CGFloat = 5.0
let resourcePullDamper: CGFloat = 0.015

class EntityManager {
  
  lazy var componentSystems: [GKComponentSystem] = {
    let aliasComponent = GKComponentSystem(componentClass: AliasComponent.self)
    let interfaceComponent = GKComponentSystem(componentClass: InterfaceComponent.self)
    return [aliasComponent, interfaceComponent]
  }()
  
  var playerEntites: [GKEntity] = [
    General(imageName: "spaceman-idle-0", team: .team1),
    General(imageName: "spaceman-idle-0", team: .team2)
  ]
  var resourcesEntities = [GKEntity]()
  var wallEntities = [GKEntity]()
  var tutorialEntities = [GKEntity]()
  var uiEntities = Set<GKEntity>()
  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  
  var currentPlayerIndex = 0
  var isHost: Bool { currentPlayerIndex == 0 }
  
  var hero: GKEntity? {
    guard playerEntites.count > 0 else { return nil }
    guard currentPlayerIndex < playerEntites.count else { return nil }
    
    return playerEntites[currentPlayerIndex]
  }
  
  var deposit: GKEntity? {
    let deposit = entities.first { entity -> Bool in
      guard let _ = entity as? Deposit else { return false }
      
      return true
    }
    return deposit
  }
  
  var winningTeam: Team? {
    guard let deposit = deposit as? Deposit,
          let depositComponent = deposit.component(ofType: DepositComponent.self) else { return nil }
    
    if depositComponent.team1Deposits >= resourcesNeededToWin {
      return Team.team1
    }
    
    if depositComponent.team2Deposits >= resourcesNeededToWin {
      return Team.team2
    }
    
    return nil
  }
  
  var panelFactory = PanelFactory()
  
  private var resourceNode : SKShapeNode?
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
    
    spawnResourceNode()
  }
  
}

extension EntityManager {
  
  func add(_ entity: GKEntity) {
    entities.insert(entity)
    
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      scene.addChild(spriteNode)
    }
    
    if let shapeNode = entity.component(ofType: ShapeComponent.self)?.node {
      scene.addChild(shapeNode)
    }
    
    if let trailNode = entity.component(ofType: TrailComponent.self)?.node {
      scene.addChild(trailNode)
    }
    
    addToComponentSysetem(entity: entity)
  }
  
  func remove(_ entity: GKEntity) {
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      spriteNode.removeFromParent()
    }
    
    if let shapeNode = entity.component(ofType: ShapeComponent.self)?.node {
      shapeNode.removeFromParent()
    }
    
    if let trailNode = entity.component(ofType: TrailComponent.self)?.node {
      trailNode.removeFromParent()
    }
    
    entities.remove(entity)
    toRemove.insert(entity)
  }
  
  func removeAllResourceEntities() {
    print("removing all resources")
    for entity in resourcesEntities {
      if let shapeComponent = entity.component(ofType: ShapeComponent.self) {
        shapeComponent.node.removeFromParent()
      }
    }
    resourcesEntities.removeAll()
  }
  
  private func addToComponentSysetem(entity: GKEntity) {
    for componentSystem in componentSystems {
      componentSystem.addComponent(foundIn: entity)
    }
  }
  
}

// MARK: - Update Methods

extension EntityManager {
  
  func update(_ deltaTime: CFTimeInterval) {
    for entity in uiEntities {
      if let scaledComponent = entity as? ScaledContainer {
        scaledComponent.updateViewPort(size: scene.viewportSize)
      }
    }
    
    for componentSystem in componentSystems {
      componentSystem.update(deltaTime: deltaTime)
    }
    
    for currentRemove in toRemove {
      for componentSystem in componentSystems {
        componentSystem.removeComponent(foundIn: currentRemove)
      }
    }
    toRemove.removeAll()
    
    updateUIElements()
    updateResourceVelocity()
  }
  
  private func updateUIElements() {
    guard let restartButton = scene.cam?.childNode(withName: AppConstants.ButtonNames.refreshButtonName) else { return }
    
    guard let hero = playerEntites[0] as? General,
          let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
          let physicsBody = heroSpriteComponent.node.physicsBody,
          !hero.isBeamed else { return }
    
    let absDx = abs(physicsBody.velocity.dx)
    let absDy = abs(physicsBody.velocity.dy)
    let notMoving = absDx < minDriftVelocity && absDy < minDriftVelocity
    //    restartButton.alpha = notMoving ? 1.0 : 0.0
  }
  
  private func updateResourceVelocity() {
    guard let deposit = scene.childNode(withName: AppConstants.ComponentNames.depositNodeName) else { return }
    
    for resource in resourcesEntities {
      guard let package = resource as? Package,
            let physicsComponent = package.component(ofType: PhysicsComponent.self),
            let shapeComponent = package.component(ofType: ShapeComponent.self) else { return }
      
      let dx = deposit.position.x - shapeComponent.node.position.x
      let dy = deposit.position.y - shapeComponent.node.position.y
      let distanceToDeposit = sqrt(pow(dx, 2.0) + pow(dy, 2.0))
      
      if distanceToDeposit < Deposit.eventHorizon {
        scene.handleDeposit(package: package)
      } else if distanceToDeposit < Deposit.pullDistance && !isHeld(resource: package) {
        let pullStength = (Deposit.pullDistance - distanceToDeposit) * resourcePullDamper
        let moveX = deposit.position.x - shapeComponent.node.position.x
        let moveY = deposit.position.y - shapeComponent.node.position.y
        let moveVector = CGVector(dx:  moveX, dy: moveY)
        let adjustedVector = moveVector.normalized() * pullStength
        physicsComponent.physicsBody.applyImpulse(adjustedVector)
      } else if package.wasThrownBy == nil && !(scene.gameState.currentState is Tutorial) {
        let xSpeed = sqrt(physicsComponent.physicsBody.velocity.dy * physicsComponent.physicsBody.velocity.dx)
        let ySpeed = sqrt(physicsComponent.physicsBody.velocity.dy * physicsComponent.physicsBody.velocity.dy)
        
        let speed = sqrt(physicsComponent.physicsBody.velocity.dx * physicsComponent.physicsBody.velocity.dx + physicsComponent.physicsBody.velocity.dy * physicsComponent.physicsBody.velocity.dy)
        
        if xSpeed <= 10.0 {
          physicsComponent.randomImpulse(y: 0.0)
        }
        
        if ySpeed <= 10.0 {
          physicsComponent.randomImpulse(x: 0.0)
        }
        
        physicsComponent.physicsBody.linearDamping = speed > Package.maxSpeed ? 0.4 : 0.0
      }
    }
  }
  
}

// MARK: - Spawn Methods

extension EntityManager {
  
  func spawnHeros(mapSize: CGSize) {
    let heroBlue = playerEntites[0]
    if let spriteComponent = heroBlue.component(ofType: SpriteComponent.self),
       let trailComponent = heroBlue.component(ofType: TrailComponent.self),
       let aliasComponent = heroBlue.component(ofType: AliasComponent.self),
       let handsComponent = heroBlue.component(ofType: HandsComponent.self) {
      
      handsComponent.didRemoveResource = { [weak self] resource in
        guard let self = self else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        self.scene.addChild(shapeComponent.node)
      }
      
      spriteComponent.node.position = CGPoint(x: 0.0, y: -mapSize.height/2 + 20)
      spriteComponent.node.zPosition = SpriteZPosition.hero.rawValue
      scene.addChild(spriteComponent.node)
      
      scene.addChild(trailComponent.node)
      
      aliasComponent.node.text = scene.getPlayerAliasAt(index: 0)
      scene.addChild(aliasComponent.node)
    }
    
    addToComponentSysetem(entity: heroBlue)
    
    let heroRed = playerEntites[1]
    if let spriteComponent = heroRed.component(ofType: SpriteComponent.self),
       let trailComponent = heroRed.component(ofType: TrailComponent.self),
       let aliasComponent = heroRed.component(ofType: AliasComponent.self),
       let handsComponent = heroRed.component(ofType: HandsComponent.self) {
      
      handsComponent.didRemoveResource = { [weak self] resource in
        guard let self = self else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        self.scene.addChild(shapeComponent.node)
      }
      
      spriteComponent.node.position = CGPoint(x: 0.0, y: mapSize.height/2 - 20)
      spriteComponent.node.zPosition = SpriteZPosition.hero.rawValue
      spriteComponent.node.zRotation = CGFloat.pi
      scene.addChild(spriteComponent.node)
      
      scene.addChild(trailComponent.node)
      
      aliasComponent.node.text = scene.getPlayerAliasAt(index: 1)
      scene.addChild(aliasComponent.node)
    }
    
    addToComponentSysetem(entity: heroRed)
  }
  
  func spawnResources() {
    guard isHost else { return }
    
    for _ in 0..<numberOfSpawnedResources {
      spawnResource()
    }
  }
  
  func spawnResource(position: CGPoint = AppConstants.Layout.boundarySize.randomPosition,
                     velocity: CGVector? = nil) {
    guard let resourceNode = resourceNode?.copy() as? SKShapeNode else { return }
    
    let resource = Package(shapeNode: resourceNode,
                           physicsBody: resourcePhysicsBody(frame: resourceNode.frame))
    if let physicsComponent = resource.component(ofType: PhysicsComponent.self) {
      
      scene.addChild(resourceNode)
      resourceNode.position = position
      DispatchQueue.main.async {
        if let vector = velocity {
          physicsComponent.physicsBody.velocity = vector
        } else {
          physicsComponent.randomImpulse()
        }
      }
    }
    
    resourceNode.strokeColor = SKColor.green
    resourcesEntities.append(resource)
  }
  
  private func resourcePhysicsBody(frame: CGRect) -> SKPhysicsBody {
    let radius = frame.size.height / 2.0
    
    let physicsBody = SKPhysicsBody(circleOfRadius: radius)
    physicsBody.friction = 0.0
    physicsBody.restitution = 1.0
    physicsBody.linearDamping = 0.0
    physicsBody.angularDamping = 0.0
    physicsBody.categoryBitMask = PhysicsCategoryMask.package
    
    // Make sure resources are only colliding on the designated host device
    if isHost {
      physicsBody.contactTestBitMask = PhysicsCategoryMask.hero | PhysicsCategoryMask.wall
      physicsBody.collisionBitMask = PhysicsCategoryMask.hero | PhysicsCategoryMask.package
    } else {
      physicsBody.contactTestBitMask = 0
      physicsBody.collisionBitMask = 0
    }
    
    return physicsBody
  }
  
  func spawnDeposit(position: CGPoint = .zero) {
    let deposit = Deposit()
    
    guard let shapeComponent = deposit.component(ofType: ShapeComponent.self) else { return }
    
    shapeComponent.node.position = position
    add(deposit)
  }
  
  func spawnField(position: CGPoint = .zero) {
    let shapeNode = SKShapeNode(circleOfRadius: 20.0)
    shapeNode.fillColor = .blue
    shapeNode.alpha = 0.5
    shapeNode.strokeColor = .white
    let physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
    let field = Field(shapeNode: shapeNode, physicsBody: physicsBody)
    
    guard let shapeComponent = field.component(ofType: ShapeComponent.self) else { return }
    
    shapeComponent.node.position = position
    add(field)
  }
  
  func spawnPanels() {
    let factory = scene.entityManager.panelFactory
    let wallPanels = factory.perimeterWallFrom(size: AppConstants.Layout.boundarySize)
    let centerPanels = self.centerPanels()
    let blinderPanels = self.blinderPanels()
    let extraPanels = self.extraPanels()
    
    for entity in wallPanels + centerPanels + blinderPanels + extraPanels {
      if let shapeNode = entity.component(ofType: ShapeComponent.self)?.node {
        scene.addChild(shapeNode)
      }
      wallEntities.append(entity)
    }
  }
  
  private func centerPanels() -> [GKEntity] {
    let position = CGPoint(x: 75.0, y: 130.0)
    let topLeftPosition = CGPoint(x: -position.x, y: position.y)
    let topLeftWall = panelFactory.panelSegment(beamConfig: .both,
                                                number: 2,
                                                position: topLeftPosition,
                                                orientation: .risingDiag)
    let topRightPosition = CGPoint(x: position.x, y: position.y)
    let topRightWall = panelFactory.panelSegment(beamConfig: .both,
                                                 number: 2,
                                                 position: topRightPosition,
                                                 orientation: .fallingDiag)
    let bottomLeftPosition = CGPoint(x: -position.x, y: -position.y)
    let bottomLeftWall = panelFactory.panelSegment(beamConfig: .both,
                                                   number: 2,
                                                   position: bottomLeftPosition,
                                                   orientation: .fallingDiag)
    let bottomRightPosition = CGPoint(x: position.x, y: -position.y)
    let bottomRightWall = panelFactory.panelSegment(beamConfig: .both,
                                                    number: 2,
                                                    position: bottomRightPosition,
                                                    orientation: .risingDiag)
    
    return topLeftWall + topRightWall + bottomLeftWall + bottomRightWall
  }
  
  private func blinderPanels() -> [GKEntity] {
    let yPosRatio: CGFloat = 0.3
    let numberOfSegments = 5
    let topBlinderPosition = CGPoint(x: 0.0,
                                     y: AppConstants.Layout.boundarySize.height * yPosRatio)
    let topBlinder = panelFactory.panelSegment(beamConfig: .both,
                                               number: numberOfSegments,
                                               position: topBlinderPosition)
    
    let bottomBlinderPosition = CGPoint(x: 0.0,
                                        y: -AppConstants.Layout.boundarySize.height * yPosRatio)
    let bottomBlinder = panelFactory.panelSegment(beamConfig: .both,
                                                  number: numberOfSegments,
                                                  position: bottomBlinderPosition)
    return topBlinder + bottomBlinder
  }
  
  private func extraPanels() -> [GKEntity] {
    let width = AppConstants.Layout.boundarySize.width
    let wallLength = AppConstants.Layout.wallSize.width
    let numberOfSegments = 2
    
    let leftBlinderPosition = CGPoint(x: -width / 2 + wallLength + 10, y: 0.0)
    let leftBlinder = panelFactory.panelSegment(beamConfig: .both,
                                                number: numberOfSegments,
                                                position: leftBlinderPosition)
    
    let rightBlinderPosition = CGPoint(x: width / 2 - wallLength - 10, y: 0.0)
    let rightBlinder = panelFactory.panelSegment(beamConfig: .both,
                                                 number: numberOfSegments,
                                                 position: rightBlinderPosition)
    return leftBlinder + rightBlinder
  }
  
  private func spawnResourceNode() {
    let width: CGFloat = 10.0
    let size = CGSize(width: width, height: width)
    
    resourceNode = SKShapeNode(rectOf: size, cornerRadius: width * 0.3)
    guard let resourceNode = resourceNode else { return }
    
    resourceNode.name = AppConstants.ComponentNames.resourceName
    resourceNode.lineWidth = 2.5
  }
  
}

// MARK: - Utility Methods

extension EntityManager {
  func heroWith(node: SKSpriteNode) -> GKEntity? {
    let player = playerEntites.first { entity -> Bool in
      guard let hero = entity as? General else { return false }
      guard let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return false }
      
      return spriteComponent.node === node
    }
    
    return player
  }
  
  func resourceWith(node: SKShapeNode) -> GKEntity? {
    let resource = resourcesEntities.first { entity -> Bool in
      guard let package = entity as? Package else { return false }
      guard let shapeComponent = package.component(ofType: ShapeComponent.self) else { return false }
      
      return shapeComponent.node === node
    }
    
    return resource
  }
  
  func panelWith(node: SKShapeNode) -> GKEntity? {
    let panel = wallEntities.first { entity -> Bool in
      guard let panelEntity = entity as? Panel,
            let beamComponent = panelEntity.component(ofType: BeamComponent.self) else { return false }
      
      let beam = beamComponent.beams.first { beam -> Bool in
        return beam === node
      }
      
      return beam == nil ? false : true
    }
    
    return panel
  }
  
  func enitityWith(node: SKNode) -> GKEntity? {
    let entity = entities.first { entity -> Bool in
      switch node {
      case is SKSpriteNode:
        guard let hero = entity as? General else { return false }
        guard let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return  false }
        
        return spriteComponent.node === node
      case is SKShapeNode:
        switch entity {
        case is Deposit:
          guard let deposit = entity as? Deposit,
                let shapeComponent = deposit.component(ofType: ShapeComponent.self) else { return false }
          
          return shapeComponent.node === node
          
        default: break
        }
      default: break
      }
      
      return false
    }
    return entity
  }
  
  func uiEntityWith(nodeName: String) -> GKEntity? {
    let element = uiEntities.first { entity -> Bool in
      guard let uiEntity = entity as? ScaledContainer else { return false }
      
      return uiEntity.node.name == nodeName
    }
    
    return element
  }
  
  func indexForResource(shape: SKShapeNode) -> Int? {
    let index = resourcesEntities.firstIndex { entity -> Bool in
      guard let package = entity as? Package else { return false }
      guard let shapeComponent = package.component(ofType: ShapeComponent.self) else { return  false }
      
      return shapeComponent.node === shape
    }
    
    return index
  }
  
  func indexForWall(panel: Panel) -> Int? {
    let index = wallEntities.firstIndex { entity -> Bool in
      guard let wall = entity as? Panel else { return false }
      return wall == panel
    }
    
    return index
  }
  
  private func isHeld(resource: Package) -> Bool {
    var isHeld = false
    playerEntites.forEach { player in
      guard isHeld == false else { return }
      guard let hero = player as? General,
            let heroHands = hero.component(ofType: HandsComponent.self),
            let shape = resource.component(ofType: ShapeComponent.self) else { return }
      
      // NOTE: Why does isHolding(resource:) not match?
      if heroHands.leftHandSlot != nil || heroHands.rightHandSlot != nil { isHeld = true}
    }
    
    return isHeld
  }
  
  func isScored(resource: Package) -> Bool {
    var isScored = false
    playerEntites.forEach { player in
      guard isScored == false else { return }
      guard let deliveredComponent = player.component(ofType: DeliveredComponent.self) else { return }
      
      if deliveredComponent.resources.contains(resource) { isScored = true }
    }
    
    return isScored
  }
  
}

// MARK: - UI Setup Methods

extension EntityManager {
  
  func addUIElements() {
    setupBackButton()
    setupThrowButton()
    setupRestartButton()
    
    if scene.gameState.currentState is Tutorial {
      addTutorialStickers()
    }
  }
  
  private func setupThrowButton() {
    let throwButton = SKSpriteNode(imageNamed: "throw")
    throwButton.name = AppConstants.ButtonNames.throwButtonName
    throwButton.alignMidBottom()
    throwButton.zPosition = SpriteZPosition.inGameUI.rawValue
    throwButton.alpha = 0.5
    
    addInGameUIView(element: throwButton)
  }
  
  private func addTutorialStickers() {
    let tapSticker = SKSpriteNode(imageNamed: "tap")
    tapSticker.name = AppConstants.ComponentNames.tutorialThrowStickerName
    tapSticker.zPosition = SpriteZPosition.inGameUI2.rawValue
    tapSticker.anchorPoint = CGPoint(x: 0.2, y: 0.9)
    tapSticker.alignMidRight()
    tapSticker.alpha = 0.0
    
    let pinchSticker = SKSpriteNode(imageNamed: "pinch-out")
    pinchSticker.name = AppConstants.ComponentNames.tutorialPinchStickerName
    pinchSticker.position = CGPoint(x: 50.0, y: -100.0)
    pinchSticker.anchorPoint = CGPoint(x: 0.2, y: 0.9)
    pinchSticker.zPosition = SpriteZPosition.inGameUI.rawValue
    
    addInGameUIViews(elements: [tapSticker, pinchSticker])
  }
  
  func removeUIElements() {
    removeInGameUIViewElements()
  }
  
  private func setupBackButton() {
    let backButton = SKShapeNode(rect: AppConstants.Layout.buttonRect,
                                 cornerRadius: AppConstants.Layout.buttonCornerRadius)
    backButton.name = AppConstants.ButtonNames.backButtonName
    backButton.zPosition = SpriteZPosition.menu.rawValue
    backButton.fillColor = AppConstants.UIColors.buttonBackground
    backButton.strokeColor = AppConstants.UIColors.buttonForeground
    backButton.alignTopLeft()
    
    let imageNode = SKSpriteNode(imageNamed: "back-white")
    imageNode.name = AppConstants.ButtonNames.backButtonName
    imageNode.zPosition = SpriteZPosition.menuLabel.rawValue
    imageNode.scale(to: backButton.frame.size)
    imageNode.color = AppConstants.UIColors.buttonForeground
    imageNode.colorBlendFactor = 1
    backButton.addChild(imageNode)
    
    addInGameUIView(element: backButton)
  }
  
  private func setupRestartButton() {
    let restartButton = SKShapeNode(rect: AppConstants.Layout.buttonRect,
                                    cornerRadius: AppConstants.Layout.buttonCornerRadius)
    restartButton.name = AppConstants.ButtonNames.refreshButtonName
    restartButton.zPosition = SpriteZPosition.menu.rawValue
    restartButton.fillColor = AppConstants.UIColors.buttonBackground
    restartButton.strokeColor = AppConstants.UIColors.buttonForeground
    restartButton.alignTopRight()
    
    let imageNode = SKSpriteNode(imageNamed: "refresh-white")
    imageNode.name = AppConstants.ButtonNames.refreshButtonName
    imageNode.zPosition = SpriteZPosition.menuLabel.rawValue
    imageNode.scale(to: restartButton.frame.size)
    imageNode.color = AppConstants.UIColors.buttonForeground
    imageNode.colorBlendFactor = 1
    restartButton.addChild(imageNode)
    
    addInGameUIView(element: restartButton)
  }
  
  private func addInGameUIViews(elements: [SKNode]) {
    for element in elements {
      addInGameUIView(element: element)
    }
  }
  
  private func addInGameUIView(element: SKNode) {
    let scaledComponent = ScaledContainer(element: element)
    
    scene.cam!.addChild(scaledComponent.node)
    
    uiEntities.insert(scaledComponent)
    addToComponentSysetem(entity: scaledComponent)
  }
  
  private func removeInGameUIViewElements() {
    for entity in uiEntities {
      if let scalableElement = entity as? ScaledContainer {
        toRemove.insert(scalableElement)
      }
    }
    
    uiEntities.removeAll()
  }
}

// MARK: - Tutorial Spawn Methods

extension EntityManager {
  
  func spawnTutorial() {
    addUIElements()
    
    loadTutorialLevel()
    
    spawnHeros(mapSize: AppConstants.Layout.tutorialBoundrySize)
    spawnDeposit()
    
    initializeTutorial()
  }
  
  private func loadTutorialLevel() {
    guard let tutorialScene = SKScene(fileNamed: "TutorialScene") else { return }
    
    tutorialScene.enumerateChildNodes(withName: AppConstants.ComponentNames.wallPanelName) { wallNode, _  in
      guard let panelSegment = self.getPanelSegment(wallNode: wallNode),
            let panelShapeComponent = panelSegment.component(ofType: ShapeComponent.self) else { return }
      
      panelShapeComponent.node.position = wallNode.position
      panelShapeComponent.node.zRotation = wallNode.zRotation
      
      self.scene.addChild(panelShapeComponent.node)
      self.wallEntities.append(panelSegment)
    }
  }
  
  private func getPanelSegment(wallNode: SKNode) -> GKEntity? {
    let panelFactory = scene.entityManager.panelFactory
    
    var team: Team? = nil
    if let userData = wallNode.userData,
       let teamRawValue = userData[Tutorial.teamUserDataKey] as? Int {
      team = Team(rawValue: teamRawValue)
    }
    
    var config: Panel.BeamArrangment = .none
    if let userData = wallNode.userData,
       let beamsRawValue = userData[Tutorial.beamsUserDataKey] as? Int {
      
      config = Panel.BeamArrangment(rawValue: beamsRawValue)!
    }
    
    guard let panelSegment = panelFactory.panelSegment(beamConfig: config,
                                                       number: 1,
                                                       team: team).first else { return nil}
    
    return panelSegment
  }
  
  private func initializeTutorial() {
    guard let hero = playerEntites[0] as? General,
          let heroAliasComponent = hero.component(ofType: AliasComponent.self),
          let heroSpriteComponent = hero.component(ofType: SpriteComponent.self),
          let heroPhysicsComponent = hero.component(ofType: PhysicsComponent.self),
          let ghost = playerEntites[1] as? General,
          let ghostAliasComponent = ghost.component(ofType: AliasComponent.self),
          let ghostSpriteComponent = ghost.component(ofType: SpriteComponent.self),
          let ghostPhysicsComponent = ghost.component(ofType: PhysicsComponent.self) else { return }
    
    heroAliasComponent.node.text = ""
    ghostAliasComponent.node.text = ""
    
    ghost.switchToState(.moving)
    ghostSpriteComponent.node.alpha = 0.5
    ghostPhysicsComponent.physicsBody.collisionBitMask = PhysicsCategoryMask.package
    heroPhysicsComponent.physicsBody.collisionBitMask = PhysicsCategoryMask.package
    
    let tutorialActionEntity = TutorialAction(delegate: scene)
    if let tapSpriteComponent = tutorialActionEntity.component(ofType: SpriteComponent.self) {
      scene.addChild(tapSpriteComponent.node)
    }
    
    if let step = tutorialActionEntity.setupNextStep(), step == .rotateThrow {
      spawnResource(position: step.midPosition, velocity: .zero)
    }
    
    tutorialEntities.append(tutorialActionEntity)
  }
  
}
