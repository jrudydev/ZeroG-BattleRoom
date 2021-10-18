//
//  GKEntity+Components.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 7/10/21.
//  Copyright © 2021 JRudy Gaming. All rights reserved.
//

import GameKit


extension GKEntity {
  
  var shape: SKShapeNode? { component(ofType: ShapeComponent.self)?.node }
  var sprite: SKSpriteNode? { component(ofType: SpriteComponent.self)?.node }
  var physics: SKPhysicsBody? { component(ofType: PhysicsComponent.self)?.physicsBody }
  var launcher: LaunchComponent? { component(ofType: LaunchComponent.self) }
  var hands: HandsComponent? { component(ofType: HandsComponent.self) }
  var alias: AliasComponent? { component(ofType: AliasComponent.self) }
  var delivered: DeliveredComponent? { component(ofType: DeliveredComponent.self) }
  var team: TeamComponent? { component(ofType: TeamComponent.self) }

}
