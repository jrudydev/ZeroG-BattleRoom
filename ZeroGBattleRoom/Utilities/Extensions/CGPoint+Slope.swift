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
    return y > x * slope + b
  }
  
  func vectorTo(point: CGPoint) -> CGVector {
    return CGVector(dx: point.x - x, dy: point.y - y)
  }
  
  func intersection(m1: CGFloat, P2: CGPoint, m2: CGFloat) -> CGPoint {
    // Note: Point/slope form intersection equations
    //
    // Solve for x: m1(x - P1x) + P1y = m2(x - P2x) + P2y
    // m1(x - P1x) = m2(x - P2x) + P2y - P1y
    // m1(x) - m1(P1x) = m2(x) - m2(P2x) + P2y - P1y
    // m1(x) = m2(x) - m2(P2x) + P2y - P1y + m1(P1x)
    // m1(x) - m2(x) = -m2(P2x) + P2y - P1y + m1(P1x)
    // x(m1 - m2) = -m2(P2x) + P2y - P1y + m1(P1x)
    // x = (-m2(P2x) + P2y - P1y + m1(P1x)) / (m1 - m2)
    //
    // Solve for y: y = m(x - Px) + Py
    
    
    let newX = (-1 * m2 * P2.x + P2.y - y + m1 * x) / (m1 - m2)
    let newY = m1 * x - m1 * x + y
    return CGPoint(x: newX, y: newY)
  }
  
  func slopeTo(point: CGPoint) -> CGFloat {
    // Note: Slope equation: m = (y - Py) / (x - Px)
    return (y - point.y) / (x - point.x)
  }
  
}

extension CGPoint {
  
  func removeInnerPoints(distance: CGFloat) -> CGPoint {
    var point = self
    switch point.x {
    case -distance...0: point.x = -distance
    case 0...distance: point.x = distance
    default: break
    }
    
    switch point.y {
    case -distance...0: point.y = -distance
    case 0...distance: point.y = distance
    default: break
    }
    
    return point
  }
  
}
