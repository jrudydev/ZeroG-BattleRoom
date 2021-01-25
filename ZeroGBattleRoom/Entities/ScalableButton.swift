//
//  ScalableButton.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 8/13/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class ScalableButton: GKEntity {
  
  let node: SKNode

  init(node: SKNode) {
    self.node = node
    
    super.init()
    
    self.addComponent(InterfaceComponent(node: node))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateViewPort(size: CGSize) {
    guard let interfaceComponent = self.component(ofType: InterfaceComponent.self) else { return }
    
    interfaceComponent.viewport = size
  }

}
