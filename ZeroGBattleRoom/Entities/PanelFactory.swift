//
//  PanelFactory.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/7/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


struct PanelFactory {
  enum WallOrientation {
    case vertical
    case horizontal
    case fallingDiag
    case risingDiag
    
    var isDiag: Bool {
      return self == .fallingDiag || self == .risingDiag
    }
  }
  
  private func createWallEntity(beamConfig: Panel.BeamArrangment) -> GKEntity {
    let shape = SKShapeNode(rectOf: AppConstants.Layout.wallSize,
                            cornerRadius: AppConstants.Layout.wallCornerRadius)
    shape.name = AppConstants.ComponentNames.wallPanelName
    shape.lineWidth = 2.5
    shape.fillColor = UIColor.gray
    shape.strokeColor = UIColor.white
    
    let physicsBody = SKPhysicsBody(rectangleOf: shape.frame.size)
    physicsBody.isDynamic = false

    return Panel(shapeNode: shape, physicsBody: physicsBody, config: beamConfig)
  }
  
  private func numberOfSegments(length: CGFloat, wallSize: CGFloat) -> Int {
    var segments = length / wallSize
    
    if length.truncatingRemainder(dividingBy: wallSize) != 0 {
      segments += 1
    }
    
    return Int(segments)
  }
}

extension PanelFactory {
  func perimeterWallFrom(size: CGSize) -> [GKEntity] {
    let widthSegments = self.numberOfSegments(length: size.width,
                                              wallSize: AppConstants.Layout.wallSize.width)
    let heightSegments = self.numberOfSegments(length: size.height,
                                               wallSize: AppConstants.Layout.wallSize.width)
      
    let size = AppConstants.Layout.boundarySize
    let topWall = self.panelSegment(beamConfig: .top,
                                    number: widthSegments,
                                    position: CGPoint(x: 0.0, y: -size.height/2))
    let bottomWall = self.panelSegment(beamConfig: .bottom,
                                       number: widthSegments,
                                       position: CGPoint(x: 0.0, y: size.height/2))
    let leftWall = self.panelSegment(beamConfig: .bottom,
                                    number: heightSegments,
                                    position: CGPoint(x: -size.width/2, y: 0.0),
                                    orientation: .vertical)
    let rightWall = self.panelSegment(beamConfig: .top,
                                      number: heightSegments,
                                      position: CGPoint(x: size.width/2, y: 0.0),
                                      orientation: .vertical)
      
    return topWall + bottomWall + leftWall + rightWall
  }
    
  func panelSegment(beamConfig: Panel.BeamArrangment,
                    number: Int,
                    position: CGPoint = .zero,
                    orientation: WallOrientation = .horizontal) -> [GKEntity] {
    var segments = [GKEntity]()
      
    var currentPosition = orientation.startingPosition(numberOfWalls: number)
    for _ in 0..<number {
      defer { currentPosition = orientation.nextPosition(position: currentPosition)}

      let panelEntity = self.createWallEntity(beamConfig: beamConfig)
      if let shapeComponent = panelEntity.component(ofType: ShapeComponent.self) {
        shapeComponent.node.position = CGPoint(x: currentPosition.x + position.x,
                                               y: currentPosition.y + position.y)
        shapeComponent.node.zRotation = orientation.rotation
      }
      
      segments.append(panelEntity)
    }
    return segments
  }
}

extension PanelFactory.WallOrientation {
  var rotation: CGFloat {
    switch self {
    case .vertical: return CGFloat.pi / 2
    case .horizontal: return 0.0
    case .fallingDiag: return -CGFloat.pi / 4
    case .risingDiag: return CGFloat.pi / 4
    }
  }
  
  func startingPosition(numberOfWalls: Int) -> CGPoint {
    let size = AppConstants.Layout.wallSize
    let wallLength = self.isDiag ? size.width * 0.35 : size.width
//    let wallThickness = size.height
    let wallWidth = wallLength * CGFloat(numberOfWalls)
    
    var startingPoint = CGPoint.zero
    if case .horizontal = self {
      startingPoint.x = -wallWidth / 2 + wallLength / 2
      startingPoint.y = 0.0
    }
    
    if case .vertical = self {
      startingPoint.x = 0.0
      startingPoint.y = -wallWidth / 2 + wallLength / 2
    }
    
    if case .fallingDiag = self {
      startingPoint.x = -wallWidth / 2// + wallThickness / 2
      startingPoint.y = wallWidth / 2// + wallLength / 2
    }
    
    if case .risingDiag = self {
      startingPoint.x = -wallWidth / 2// + wallThickness / 2
      startingPoint.y = -wallWidth / 2// + wallLength / 2
    }
    
    return startingPoint
  }
  
  func nextPosition(position: CGPoint) -> CGPoint {
    let wallLength = AppConstants.Layout.wallSize.width
    
    var nextPoint = position
    if case .horizontal = self {
      nextPoint.x = position.x + wallLength
      nextPoint.y = position.y
    }
    
    if case .vertical = self {
      nextPoint.x = position.x
      nextPoint.y = position.y + wallLength
    }
    
    if case .fallingDiag = self {
      nextPoint.x = position.x + wallLength * 0.7
      nextPoint.y = position.y - wallLength * 0.7
    }
    
    if case .risingDiag = self {
      nextPoint.x = position.x + wallLength * 0.7
      nextPoint.y = position.y + wallLength * 0.7
    }
    
    return nextPoint
  }
}
