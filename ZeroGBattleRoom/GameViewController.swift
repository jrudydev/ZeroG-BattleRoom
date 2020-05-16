//
//  GameViewController.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/27/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
import Combine


extension Notification.Name {
  static let motionShake = Notification.Name("motionShake")
}


protocol GameSceneProtocol {
  func viewResized(size: CGSize)
}


class GameViewController: UIViewController {
  
  private var viewportSize: CGSize = UIScreen.main.bounds.size
  
  private var sceneDelegate: GameSceneProtocol?
  
  private var subscriptions = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadScene()
    
    GameKitHelper.shared.gameCenterAuthPlayer() { view in
      view.dismiss(animated: true)
    }

    NotificationCenter.Publisher(center: .default, name: .restartGame, object: nil)
      .sink(receiveValue: { [weak self] notification in
        guard let self = self else { return }
//      let newScene = GameScene(fileNamed: "GameScene")!
//      newScene.scaleMode = .aspectFill
//      let reveal = SKTransition.flipVertical(withDuration: 0.5)
//      self.view?.presentScene(newScene, transition: reveal)
            
        self.viewportSize = UIScreen.main.bounds.size
        self.loadScene()
      })
      .store(in: &subscriptions)

    NotificationCenter.Publisher(center: .default, name: .resizeView, object: nil)
    .sink(receiveValue: { [weak self] notification in
      guard let self = self else { return }
      guard let dt = notification.object as? CGFloat else { return }
 
      let percent = dt * dt * dt / 100.0
      let widthUnit = (AppConstants.Layout.boundarySize.width - UIScreen.main.bounds.width) * percent
      let heightUnit = (AppConstants.Layout.boundarySize.height - UIScreen.main.bounds.height) * percent
      
      var width = self.viewportSize.width  + widthUnit
      width = min(max(width, UIScreen.main.bounds.width), AppConstants.Layout.boundarySize.width)
      var height = self.viewportSize.height  + heightUnit
      height = min(max(height, UIScreen.main.bounds.height), AppConstants.Layout.boundarySize.height)
      
      self.viewportSize = CGSize(width: width, height: height)
      self.viewDidLayoutSubviews()
      self.sceneDelegate?.viewResized(size: self.viewportSize)
    })
    .store(in: &subscriptions)
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portraitUpsideDown
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let view = self.view as? SKView else { return }
    let resize = view.frame.size.asepctFill(self.viewportSize)
    view.scene?.size = resize
  }
  
  override func becomeFirstResponder() -> Bool {
      return true
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
      if motion == .motionShake {
          NotificationCenter.default.post(name: .motionShake, object: nil)
      }
  }
}

extension GameViewController {
  // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
  // including entities and graphs.
  private func loadScene() {
    if let scene = GKScene(fileNamed: "GameScene") {
      
      // Get the SKScene from the loaded GKScene
      if let sceneNode = scene.rootNode as! GameScene? {
        
        // Copy gameplay related content over to the scene
//        sceneNode.entities = scene.entities
//        sceneNode.graphs = scene.graphs
        
        // Set the scale mode to scale to fit the window
        sceneNode.scaleMode = .aspectFill
//        sceneNode.viewportSize = viewportSize
        
        // Present the scene
        if let view = self.view as! SKView? {
          view.presentScene(sceneNode)
          
          view.ignoresSiblingOrder = true
          
//          view.showsFPS = true
//          view.showsNodeCount = true
//          view.showsPhysics = true
        }
        
        self.sceneDelegate = sceneNode
        
        let networking = MultiplayerNetworking()
        sceneNode.multiplayerNetworking = networking
        self.setupNetworkingNotifcations(networking: networking, delegate: sceneNode)
      }
    }
    
    self.viewDidLayoutSubviews()
  }
  
  private func setupNetworkingNotifcations(networking: MultiplayerNetworking,
                                           delegate: MultiplayerNetworkingProtocol) {
    
    networking.delegate = delegate
    NotificationCenter.Publisher(center: .default, name: .startMatchmaking, object: nil)
      .sink(receiveValue: { notification in
        GameKitHelper.shared.findMatch(vc: self, delegate: networking) { vc in
          
        }
      })
      .store(in: &subscriptions)
  }
}
