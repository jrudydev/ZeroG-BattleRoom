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


class EntityManager {
  
  lazy var componentSystems: [GKComponentSystem] = {
    let aliasComponent = GKComponentSystem(componentClass: AliasComponent.self)
    return [aliasComponent]
  }()
  
  var playerEntites = [GKEntity]()
  var resourcesEntities = [GKEntity]()
  var wallEntities = [GKEntity]()
  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  
  var currentPlayerIndex = 0
  var resourcesDelivered = 0
  
  var hero: GKEntity? {
    guard self.playerEntites.count > 0 else { return nil }
    guard self.currentPlayerIndex < self.playerEntites.count else { return nil }
    
    return self.playerEntites[self.currentPlayerIndex]
  }
  
  var deposit: GKEntity? {
    let deposit = self.entities.first { entity -> Bool in
      guard let _ = entity as? Deposit else { return false }
      
      return true
    }
    return deposit
  }
  
  var winningTeam: Team? {
    guard let deposit = self.deposit as? Deposit,
      let depositComponent = deposit.component(ofType: DepositComponent.self) else { return nil }
    
    if depositComponent.team1Deposits >= resourcesNeededToWin {
      return Team.team1
    }
    
    if depositComponent.team2Deposits >= resourcesNeededToWin {
      return Team.team2
    }
    
    return nil
  }
  
  private var resourceNode : SKShapeNode?
  private var spinnyNode : SKShapeNode?
  var spinnyNodeCopy: SKShapeNode? {
    return self.spinnyNode?.copy() as? SKShapeNode
  }
  
  private var panelFactory = PanelFactory()
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
    
    self.createResourceNode()
    self.createSpinnyNode()
  }
  
  func add(_ entity: GKEntity) {
    self.entities.insert(entity)
    
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      self.scene.addChild(spriteNode)
    }
    
    if let shapeNode = entity.component(ofType: ShapeComponent.self)?.node {
      self.scene.addChild(shapeNode)
    }
    
    if let trailNode = entity.component(ofType: TrailComponent.self)?.node {
      self.scene.addChild(trailNode)
    }
    
    self.addToComponentSysetem(entity: entity)
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
    
    self.entities.remove(entity)
    self.toRemove.insert(entity)
  }
  
  func update(_ deltaTime: CFTimeInterval) {
    for componentSystem in self.componentSystems {
      componentSystem.update(deltaTime: deltaTime)
    }
    
    for currentRemove in toRemove {
      for componentSystem in self.componentSystems {
        componentSystem.removeComponent(foundIn: currentRemove)
      }
    }
    self.toRemove.removeAll()
    
    self.updateResourceVelocity()
  }
  
  private func addToComponentSysetem(entity: GKEntity) {
    for componentSystem in self.componentSystems {
      componentSystem.addComponent(foundIn: entity)
    }
  }
  
  private func updateResourceVelocity() {
    let maxSpeed: CGFloat = 400.0
    for resource in self.resourcesEntities {
      guard let physicsComponent = resource.component(ofType: PhysicsComponent.self) else { return }
      
      let xSpeed = sqrt(physicsComponent.physicsBody.velocity.dy * physicsComponent.physicsBody.velocity.dx)
      let ySpeed = sqrt(physicsComponent.physicsBody.velocity.dy * physicsComponent.physicsBody.velocity.dy)
      
      let speed = sqrt(physicsComponent.physicsBody.velocity.dx * physicsComponent.physicsBody.velocity.dx + physicsComponent.physicsBody.velocity.dy * physicsComponent.physicsBody.velocity.dy)
      
      if xSpeed <= 10.0 {
        physicsComponent.randomImpulse(y: 0.0)
      }
      
      if ySpeed <= 10.0 {
        physicsComponent.randomImpulse(x: 0.0)
      }
      
      physicsComponent.physicsBody.linearDamping = speed > maxSpeed ? 0.4 : 0.0
    }
  }
}

extension EntityManager {
  func spawnHeros() {
    let heroBlue = General(imageName: "blue_spaceguy", team: .team1, resourceReleased: {
      [weak self] shape in
      
      guard let self = self else { return }
      
      self.scene.addChild(shape)
    })
    if let spriteComponent = heroBlue.component(ofType: SpriteComponent.self),
      let trailComponent = heroBlue.component(ofType: TrailComponent.self),
      let aliasComponent = heroBlue.component(ofType: AliasComponent.self) {
      spriteComponent.node.position = CGPoint(x: 0.0,
                                              y: -AppConstants.Layout.boundarySize.height/2 + 20)
      aliasComponent.node.text = "Player 1 (0/\(resourcesNeededToWin))"
      self.scene.addChild(spriteComponent.node)
      
      self.scene.addChild(trailComponent.node)
    }
    self.playerEntites.append(heroBlue)
    self.addToComponentSysetem(entity: heroBlue)
    
    let heroRed = General(imageName: "red_spaceguy", team: .team2, resourceReleased: {
      [weak self] shape in
      
      guard let self = self else { return }
      
      self.scene.addChild(shape)
    })
    if let spriteComponent = heroRed.component(ofType: SpriteComponent.self),
      let trailComponent = heroRed.component(ofType: TrailComponent.self),
      let aliasComponent = heroRed.component(ofType: AliasComponent.self) {
      
      spriteComponent.node.position = CGPoint(x: 0.0,
                                              y: AppConstants.Layout.boundarySize.height/2 - 20)
      aliasComponent.node.text = "Player 2 (0/\(resourcesNeededToWin))"
      spriteComponent.node.zRotation = CGFloat.pi
      self.scene.addChild(spriteComponent.node)
      
      self.scene.addChild(trailComponent.node)
    }
    self.playerEntites.append(heroRed)
    self.addToComponentSysetem(entity: heroRed)
  }
  
  func spawnResource(position: CGPoint = AppConstants.Layout.boundarySize.randomPosition,
                     vector: CGVector? = nil) {
    guard let resourceNode = self.resourceNode?.copy() as? SKShapeNode else { return }
    
    let resource = Package(shapeNode: resourceNode)
    if let shapeComponent = resource.component(ofType: ShapeComponent.self),
      let physicsComponent = resource.component(ofType: PhysicsComponent.self) {
      
      self.scene.addChild(shapeComponent.node)
      shapeComponent.node.position = position
      DispatchQueue.main.async {
        if let vector = vector {
          physicsComponent.physicsBody.velocity = vector
        } else {
          physicsComponent.randomImpulse()
        }
      }
    }
    
    resourceNode.strokeColor = SKColor.green
    self.resourcesEntities.append(resource)
  }
    
  func spawnDeposit(position: CGPoint = .zero) {
    let deposit = Deposit()
    
    guard let shapeComponent = deposit.component(ofType: ShapeComponent.self) else { return }
    
    shapeComponent.node.position = position
    self.add(deposit)
  }
  
  func spawnPanels() {
    let factory = self.scene.entityManager.panelFactory
    let wallPanels = factory.perimeterWallFrom(size: AppConstants.Layout.boundarySize)
    let centerPanels = self.centerPanels()
    let blinderPanels = self.blinderPanels()
    let extraPanels = self.extraPanels()
    
    for entity in wallPanels + centerPanels + blinderPanels + extraPanels {
      self.add(entity)
      self.wallEntities.append(entity)
    }
  }
  
  private func centerPanels() -> [GKEntity] {
    let position = CGPoint(x: 80.0, y: 120.0)
    let topLeftPosition = CGPoint(x: -position.x, y: position.y)
    let topLeftWall = self.panelFactory.panelSegment(beamConfig: .both,
                                                     number: 2,
                                                     position: topLeftPosition,
                                                     orientation: .risingDiag)
    let topRightPosition = CGPoint(x: position.x, y: position.y)
    let topRightWall = self.panelFactory.panelSegment(beamConfig: .both,
                                                      number: 2,
                                                      position: topRightPosition,
                                                      orientation: .fallingDiag)
    let bottomLeftPosition = CGPoint(x: -position.x, y: -position.y)
    let bottomLeftWall = self.panelFactory.panelSegment(beamConfig: .both,
                                                        number: 2,
                                                        position: bottomLeftPosition,
                                                        orientation: .fallingDiag)
    let bottomRightPosition = CGPoint(x: position.x, y: -position.y)
    let bottomRightWall = self.panelFactory.panelSegment(beamConfig: .both,
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
    let topBlinder = self.panelFactory.panelSegment(beamConfig: .both,
                                                    number: numberOfSegments,
                                                    position: topBlinderPosition)
    
    let bottomBlinderPosition = CGPoint(x: 0.0,
                                        y: -AppConstants.Layout.boundarySize.height * yPosRatio)
    let bottomBlinder = self.panelFactory.panelSegment(beamConfig: .both,
                                                       number: numberOfSegments,
                                                       position: bottomBlinderPosition)
    return topBlinder + bottomBlinder
  }
  
  private func extraPanels() -> [GKEntity] {
    let width = AppConstants.Layout.boundarySize.width
    let wallLength = AppConstants.Layout.wallSize.width
    let numberOfSegments = 2
  
    let leftBlinderPosition = CGPoint(x: -width / 2 + wallLength + 10, y: 0.0)
    let leftBlinder = self.panelFactory.panelSegment(beamConfig: .both,
                                                     number: numberOfSegments,
                                                     position: leftBlinderPosition)
 
    let rightBlinderPosition = CGPoint(x: width / 2 - wallLength - 10, y: 0.0)
    let rightBlinder = self.panelFactory.panelSegment(beamConfig: .both,
                                                      number: numberOfSegments,
                                                      position: rightBlinderPosition)
    return leftBlinder + rightBlinder
  }
}

extension EntityManager {
  private func createResourceNode() {
    let width: CGFloat = 10.0
    let size = CGSize(width: width, height: width)
    
    self.resourceNode = SKShapeNode(rectOf: size, cornerRadius: width * 0.3)
    guard let resourceNode = self.resourceNode else { return }
    
    resourceNode.name = AppConstants.ComponentNames.resourceName
    resourceNode.lineWidth = 2.5
  }
  
  private func createSpinnyNode() {
    let frame = UIScreen.main.bounds
    let width = (frame.size.width + frame.size.height) * 0.05
    self.spinnyNode = SKShapeNode(rectOf: CGSize(width: width, height: width),
                                  cornerRadius: width * 0.3)
    
    
    guard let spinnyNode = self.spinnyNode else { return }
    
    spinnyNode.lineWidth = 2.5
    
    spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
    spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                      SKAction.fadeOut(withDuration: 0.5),
                                      SKAction.removeFromParent()]))
  }
}

extension EntityManager {
  func heroWith(node: SKSpriteNode) -> GKEntity? {
    let player = self.playerEntites.first { entity -> Bool in
      guard let hero = entity as? General else { return false }
      guard let spriteComponent = hero.component(ofType: SpriteComponent.self) else { return false }
      
      return spriteComponent.node === node
    }
    
    return player
  }
  
  func resourceWith(node: SKShapeNode) -> GKEntity? {
    let resource = self.resourcesEntities.first { entity -> Bool in
      guard let package = entity as? Package else { return false }
      guard let shapeComponent = package.component(ofType: ShapeComponent.self) else { return false }
      
      return shapeComponent.node === node
    }
    
    return resource
  }
  
  func panelWith(node: SKShapeNode) -> GKEntity? {
    let panel = self.entities.first { entity -> Bool in
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
    let entity = self.entities.first { entity -> Bool in
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
  
  func indexForResource(shape: SKShapeNode) -> Int? {
    let index = self.resourcesEntities.firstIndex { entity -> Bool in
      guard let package = entity as? Package else { return false }
      guard let shapeComponent = package.component(ofType: ShapeComponent.self) else { return  false }
      
      return shapeComponent.node === shape
    }
    
    return index
  }
  
  func indexForWall(panel: Panel) -> Int? {
    let index = self.wallEntities.firstIndex { entity -> Bool in
      guard let wall = entity as? Panel else { return false }
      return wall == panel
    }
    
    return index
  }
}
