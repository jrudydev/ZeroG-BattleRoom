//
//  TrailComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/5/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class TrailComponent: GKComponent {
  
  enum TrailType {
    case resource
    case team1
    case team2
    
    var filename: String {
      switch self {
      case .resource: return "BallTrail-Silver"
      case .team1: return "BallTrail-Red"
      case .team2: return "BallTrail-Blue"
      }
    }
    
    var alpha: CGFloat {
      switch self {
      case .team1, .team2: return 1.0
      case .resource: return 0.15
      }
    }
  }
  
  let node = SKNode()
  
  lazy var emitter = SKEmitterNode(fileNamed: type.filename)
  
  var type: TrailType {
    didSet {
      guard let emitter = emitter else { return }
      
      let parent = emitter.parent
      
      emitter.removeFromParent()
      
      let newEmitter = SKEmitterNode(fileNamed: type.filename)
      newEmitter?.particleAlpha = type.alpha
      newEmitter?.targetNode = node
      
      if let newEmitter = newEmitter,
         let emitterParent = parent {
        emitterParent.addChild(newEmitter)
      }
      
      self.emitter = newEmitter
    }
  }
  
  var alpha: CGFloat? {
    get {
      emitter?.alpha
    }
    set {
      guard let value = newValue else { return }
      
      emitter?.alpha = value
    }
  }
  
  init(type: TrailType = .resource) {
    self.type = type
    
    super.init()
    
    self.emitter?.targetNode = self.node
    self.emitter?.particleAlpha = type.alpha
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
