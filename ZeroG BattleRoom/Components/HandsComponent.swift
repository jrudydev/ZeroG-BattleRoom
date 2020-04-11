//
//  ResourceComponent.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/4/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class HandsComponent: GKComponent {
  
  var leftHandSlot: Package? = nil {
    willSet {
      if newValue != nil {
        guard let resource = newValue else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
      } else {
        guard let resource = self.leftHandSlot else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
        self.didRemoveResourece(shapeComponent.node)
      }
    }
    
    didSet {
      guard let resource = self.leftHandSlot else { return }
      guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
      
      shapeComponent.node.position = CGPoint(x: 10.0, y: 10.0)
      self.didSetResource(shapeComponent.node)
    }
  }
  
  var rightHandSlot: Package? = nil {
    willSet {
      if newValue != nil {
        guard let resource = newValue else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
      } else {
        guard let resource = self.rightHandSlot else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
        self.didRemoveResourece(shapeComponent.node)
      }
    }
    
    didSet {
      guard let resource = self.rightHandSlot else { return }
      guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
      
      shapeComponent.node.position = CGPoint(x: -10.0, y: 10.0)
      self.didSetResource(shapeComponent.node)
    }
  }
  
  var isImpacted = false {
    didSet {
      guard self.isImpacted == true else { return }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        guard let self = self else { return }
        
        self.isImpacted = false
      }
    }
  }
  
  private var heldResources: [Package] {
    var packages = [Package]()
    
    if let leftHandPackage = self.leftHandSlot {
      packages.append(leftHandPackage)
    }
    
    if let rightHandPackage = self.rightHandSlot {
      packages.append(rightHandPackage)
    }
    
    return packages
  }
  
  private let didSetResource: (SKShapeNode) -> Void
  private let didRemoveResourece: (SKShapeNode) -> Void
  
  init(didSetResource: @escaping (SKShapeNode) -> Void,
       didRemoveResourece: @escaping (SKShapeNode) -> Void) {
    self.didSetResource = didSetResource
    self.didRemoveResourece = didRemoveResourece
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func isHolding(shapeComponent: ShapeComponent) -> Bool {
    for packageComponent in self.heldResources {
      if let shapeComponent = packageComponent.component(ofType: ShapeComponent.self),
        shapeComponent.node == packageComponent {
        
        return true
      }
    }
    return false
  }
}

extension HandsComponent {
  func grab(resource: Package) {
    if self.leftHandSlot == nil {
      self.leftHandSlot = resource
    }
    
    if self.rightHandSlot == nil {
      self.rightHandSlot = resource
    }
  }
  
  @discardableResult
  func release(resource: Package) -> Package? {
    guard let resourceShapeComponent = resource.component(ofType: ShapeComponent.self) else { return nil }
    
    if let item = self.leftHandSlot,
      let itemShapeComponent = item.component(ofType: ShapeComponent.self),
      itemShapeComponent.node === resourceShapeComponent.node {
    
      self.leftHandSlot = nil
      return resource
    }
    
    if let item = self.rightHandSlot,
      let itemShapeComponent = item.component(ofType: ShapeComponent.self),
      itemShapeComponent.node === resourceShapeComponent.node {
    
      self.leftHandSlot = nil
      return resource
    }
    
    return nil
  }
}
