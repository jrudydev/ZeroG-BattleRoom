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
  
  let node: SKEffectNode

  init(effect: SKEffectNode) {
    self.node = effect
    
    super.init()
    
    self.addComponent(InterfaceComponent(node: effect))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateViewPort(size: CGSize) {
    guard let interfaceComponent = self.component(ofType: InterfaceComponent.self) else { return }
    
    interfaceComponent.viewport = size
  }

}
