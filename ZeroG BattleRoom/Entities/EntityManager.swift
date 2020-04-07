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


let numberOfSpawnedResources = 3
let resourcesNeededToWin = 6


class EntityManager {
  
  lazy var componentSystems: [GKComponentSystem] = {
    let aliasComponent = GKComponentSystem(componentClass: AliasComponent.self)
    return [aliasComponent]
  }()
  
  var playerEntites = [GKEntity]()
  var resourcesEntities = [GKEntity]()
  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  
  var hero: GKEntity? {
    return self.playerEntites[self.scene.viewModel.currentPlayerIndex]
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
  
  unowned let scene: GameScene
  
  init(scene: GameScene) {
    self.scene = scene
    
    self.createResourceNode()
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
  }
  
  private func addToComponentSysetem(entity: GKEntity) {
    for componentSystem in self.componentSystems {
      componentSystem.addComponent(foundIn: entity)
    }
  }
}

extension EntityManager {
  func spawnHeros() {
    let heroBlue = General(imageName: "blue_spaceguy", team: .team1, addShape: {
      [weak self] shape in
      
      guard let self = self else { return }
      
      self.scene.addChild(shape)
    })
    if let spriteComponent = heroBlue.component(ofType: SpriteComponent.self),
      let aliasComponent = heroBlue.component(ofType: AliasComponent.self) {
      spriteComponent.node.position = CGPoint(x: 0.0,
                                              y: -AppConstants.Layout.boundarySize.height/2 + 20)
      aliasComponent.node.text = "Player 1"
      self.scene.addChild(spriteComponent.node)
    }
    self.playerEntites.append(heroBlue)
    self.addToComponentSysetem(entity: heroBlue)
    
    let heroRed = General(imageName: "red_spaceguy", team: .team2, addShape: {
      [weak self] shape in
      
      guard let self = self else { return }
      
      self.scene.addChild(shape)
    })
    if let spriteComponent = heroRed.component(ofType: SpriteComponent.self),
      let aliasComponent = heroRed.component(ofType: AliasComponent.self) {
      
      spriteComponent.node.position = CGPoint(x: 0.0,
                                              y: AppConstants.Layout.boundarySize.height/2 - 20)
      aliasComponent.node.text = "Player 2"
      spriteComponent.node.zRotation = CGFloat.pi
      self.scene.addChild(spriteComponent.node)
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
    
    if let shapeComponent = deposit.component(ofType: ShapeComponent.self) {
      shapeComponent.node.position = position
    }
    
    self.add(deposit)
  }
  
  func spawnWalls() {
    let wall = self.createWallEntity()
    
    self.add(wall)
  }
  
}

extension EntityManager {
  private func createWallEntity() -> GKEntity {
    let shape = SKShapeNode(rectOf: AppConstants.Layout.wallSize,
                            cornerRadius: AppConstants.Layout.wallCornerRadius)
    shape.name = AppConstants.ComponentNames.wallPanelName
    shape.lineWidth = 2.5
    shape.fillColor = UIColor.gray
    shape.strokeColor = UIColor.white
    
    let physicsBody = SKPhysicsBody(rectangleOf: shape.frame.size)
    physicsBody.isDynamic = false

    return Panel(shapeNode: shape, physicsBody: physicsBody)
  }
  
  private func createResourceNode() {
    let width: CGFloat = 10.0
    let size = CGSize(width: width, height: width)
    
    self.resourceNode = SKShapeNode(rectOf: size, cornerRadius: width * 0.3)
    guard let resourceNode = self.resourceNode else { return }
    
    resourceNode.name = AppConstants.ComponentNames.resourceName
    resourceNode.lineWidth = 2.5
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
        let beamComponent = panelEntity.component(ofType: TracktorBeamComponent.self) else { return false }
      
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
}
