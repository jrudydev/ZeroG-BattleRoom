//
//  MenuButton.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/20/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class ButtonLabel: GKEntity {
  
  let node = SKNode()

  init(text: String, fontSize: CGFloat) {
    super.init()
    
    let label = SKLabelNode(text: text)
    label.name = AppConstants.ComponentNames.backButtonName
    label.fontSize = fontSize
    label.zPosition = 100
    label.isUserInteractionEnabled = false
    self.node.addChild(label)
    
    self.addComponent(InGameUIComponent(node: self.node,
                                        viewport: UIScreen.main.bounds.size,
                                        normalizedPosition: CGPoint(x: 0.12, y: 0.05)))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateViewPort(size: CGSize) {
    guard let uiComponent = self.component(ofType: InGameUIComponent.self) else { return }
    
    uiComponent.viewport = size
  }

}
