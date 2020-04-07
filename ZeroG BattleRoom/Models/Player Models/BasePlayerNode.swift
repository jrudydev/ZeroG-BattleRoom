//
//  BasePlayer.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/30/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

class BasePlayerNode: SKNode {
  private var playerAliasLabel: SKLabelNode!
  private var playerSprite: SKSpriteNode!
  
  convenience init(fileNamed: String) {
    self.init()
    
    self.setupPlayerSprite(fileNamed: fileNamed)
    self.setupAliasLabel()
  }
  
  func setPlayerAliasText(playerAlias: String) {
    self.playerAliasLabel?.text = playerAlias
  }
  
  private func setupPlayerSprite(fileNamed: String) {
    self.playerSprite = SKSpriteNode(fileNamed: fileNamed)
  }
}

extension BasePlayerNode {
  private func setupPhysicsBody() {
    let physicsBody = SKPhysicsBody(circleOfRadius: self.playerSprite.size.width / 2)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    self.physicsBody = physicsBody
  }

  private func setupTrail(node: SKNode) {
    if let trail = SKEmitterNode(fileNamed: "BallTrail") {
      trail.targetNode = node
      self.addChild(trail)
    }
  }
  
  private func setupAliasLabel() {
    self.playerAliasLabel = SKLabelNode(fontNamed: "Arial")
    self.playerAliasLabel.fontSize = 20
    self.playerAliasLabel.fontColor = SKColor.red
    self.playerAliasLabel.position = CGPoint(x: 0.0, y: 40.0)
    self.playerAliasLabel.name = AppConstants.ComponentNames.gameMessageName
    self.addChild(self.playerAliasLabel)
  }
}


class BasePlayer: SKSpriteNode {
  enum State {
    case idle
    case moving
    case beamed
  }
  
  private var state: State = .idle
}

extension BasePlayer {
  func setupPhysicsBody() {
    let physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
    physicsBody.categoryBitMask = PhysicsCategoryMask.hero
    self.physicsBody = physicsBody
  }
  
  func setupTrail(node: SKNode) {
    if let trail = SKEmitterNode(fileNamed: "BallTrail") {
      trail.targetNode = node
      self.addChild(trail)
    }
  }
  
  func switchToState(_ state: State) {
    switch (state) {
    case .idle:
      self.physicsBody?.velocity = CGVector.zero
    case .moving:
      self.state = .moving
    case .beamed:
      self.state = .beamed
    }
  }
}
