//
//  GKEntity+Components.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 7/10/21.
//  Copyright © 2021 JRudy Gaming. All rights reserved.
//

import GameKit


extension GKEntity {

  var sprite: SKSpriteNode? {
    return component(ofType: SpriteComponent.self)?.node
  }

}
