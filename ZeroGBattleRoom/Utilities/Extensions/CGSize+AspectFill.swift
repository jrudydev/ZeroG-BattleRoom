//
//  CGSize+AspectFill.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/29/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit

extension CGSize {
  
  public func asepctFill(_ target: CGSize) -> CGSize {
    let baseAspect = self.width / self.height
    let targetAspect = target.width / target.height
    if baseAspect > targetAspect {
      return CGSize(width: (target.height * width) / height, height: target.height)
    } else {
      return CGSize(width: target.width, height: (target.width * height) / width)
    }
  }
  
  var randomResourcePosition: CGPoint {
    let halfWidth = (width - 50) / 2
    let halfHeight = (height - 50) / 2
    let randomPoint = CGPoint(x: CGFloat.random(in: -halfWidth...halfWidth),
                              y: CGFloat.random(in: -halfHeight...halfHeight))

    return randomPoint.removeInnerPoints(distance: CGFloat(AppConstants.Layout.innerDistance))
  }
  
}
