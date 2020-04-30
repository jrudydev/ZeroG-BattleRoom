//
//  TeamComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


enum Team: Int {
  case team1 = 1
  case team2
  case team3
  case team4
  
  static let allValues = [team1, team2]
  
  var color: UIColor {
    switch self {
    case .team1:
      return UIColor.blue
    case .team2:
      return UIColor.red
    case .team3:
      return UIColor.yellow
    case .team4:
      return UIColor.green
    }
  }
  
  var offColor: UIColor {
    return self.color.withAlphaComponent(0.5)
  }
  
  func oppositeTeam() -> Team {
    switch self {
    case .team1: return .team2
    case .team2: return .team1
    case .team3: return .team4
    case .team4: return .team3
    }
  }
}

class TeamComponent: GKComponent {
  
  let team: Team
  
  init(team: Team) {
    self.team = team
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
