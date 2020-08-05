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
  
  private(set) var leftHandSlot: Package? = nil {
    willSet {
      if newValue != nil {
        guard let resource = newValue else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
        resource.disableCollisionDetection()
      } else {
        guard let resource = self.leftHandSlot,
          let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
        resource.enableCollisionDetections()
        
        self.didRemoveResource?(resource)
      }
    }
    
    didSet {
      guard let entity = self.entity as? General,
        let entitySpriteComponent = entity.component(ofType: SpriteComponent.self),
        let resource = self.leftHandSlot,
        let resourceShapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
      
      resourceShapeComponent.node.position = CGPoint(x: -10.0, y: 10.0)
      entitySpriteComponent.node.addChild(resourceShapeComponent.node)
    }
  }
  
  private(set) var rightHandSlot: Package? = nil {
    willSet {
      if newValue != nil {
        guard let resource = newValue else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
        resource.disableCollisionDetection()
      } else {
        guard let resource = self.rightHandSlot else { return }
        guard let shapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
        
        shapeComponent.node.removeFromParent()
        resource.enableCollisionDetections()
        
        self.didRemoveResource?(resource)
      }
    }
    
    didSet {
      guard let entity = self.entity as? General,
        let entitySpriteComponent = entity.component(ofType: SpriteComponent.self),
        let resource = self.rightHandSlot,
        let resourceShapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
      
      resourceShapeComponent.node.position = CGPoint(x: +10.0, y: 10.0)
      entitySpriteComponent.node.addChild(resourceShapeComponent.node)
    }
  }
  
  var hasFreeHand: Bool {
    return self.leftHandSlot == nil || (self.rightHandSlot == nil && self.isOffHandEnabled)
  }
  
  var hasResourceInHand: Bool {
    return self.leftHandSlot != nil || self.rightHandSlot != nil
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
  
  private var isOffHandEnabled = true
  var didRemoveResource: ((Package) -> Void)?
  
  override init() {
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
    } else if self.rightHandSlot == nil && self.isOffHandEnabled {
      self.rightHandSlot = resource
    }
  }
  
  func release(resource: Package, point: CGPoint = .zero) {
    guard let resourceShapeComponent = resource.component(ofType: ShapeComponent.self) else { return }
    
    if let package = self.leftHandSlot,
      let shapeComponent = package.component(ofType: ShapeComponent.self),
      shapeComponent.node === resourceShapeComponent.node {
    
      self.leftHandSlot = nil

      DispatchQueue.main.async {
        shapeComponent.node.position = point
      }
    } else if let package = self.rightHandSlot,
      let shapeComponent = package.component(ofType: ShapeComponent.self),
      shapeComponent.node === resourceShapeComponent.node {
    
      self.rightHandSlot = nil
      
      DispatchQueue.main.async {
        shapeComponent.node.position = point
      }
    }
  }
}
