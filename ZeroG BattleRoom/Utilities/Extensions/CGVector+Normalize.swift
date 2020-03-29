//
//  CGVector+Normalize.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/25/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

extension CGVector {
  public func length() -> CGFloat {
    return sqrt(self.dx * self.dx + self.dy * self.dy)
  }
  
  func normalized() -> CGVector {
    let length = self.length()
    return length > 0 ? self / length : CGVector.zero
  }
  
  static public func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
  }
}
