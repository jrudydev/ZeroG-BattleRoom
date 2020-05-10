//
//  CGPoint+Slope.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 5/10/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit


extension CGPoint {
  func isAbove(point: CGPoint, slope: CGFloat) -> Bool {
    guard slope != 0 || slope != CGFloat.infinity else { return false }
    
    // PointSlope Line Formula: y = xm + b
    // b = y - xm
    let b = point.y - point.x * slope
  
    // Check if point is above with this formula: y > xm + b
    return self.y > self.x * slope + b
  }
}
