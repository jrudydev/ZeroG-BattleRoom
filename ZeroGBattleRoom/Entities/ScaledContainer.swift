//
//  UserInterface.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class ScaledContainer: GKEntity {
  
  let node: SKNode

  init(name: String, elements: [SKNode]) {
    let node = SKNode()
    node.name = name
    self.node = node
    
    super.init()
    
    for element in elements {
      self.node.addChild(element)
      self.addComponent(InterfaceComponent(node: element))
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateViewPort(size: CGSize) {
    guard let interfaceComponent = self.component(ofType: InterfaceComponent.self) else { return }
    
    interfaceComponent.viewport = size
  }

}
