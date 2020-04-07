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

class GameViewController: UIViewController {
  
  var subscriptions = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadScene()
    
    GameKitHelper.shared.gameCenterAuthPlayer() { view in
      view.dismiss(animated: true)
    }

    NotificationCenter.Publisher(center: .default, name: .restartGame, object: nil)
      .sink(receiveValue: { [weak self] notification in
        guard let self = self else { return }
        
        self.loadScene()
      })
      .store(in: &subscriptions)
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let view = self.view as? SKView else { return }
    let resize = view.frame.size.asepctFill(UIScreen.main.bounds.size)
    view.scene?.size = resize
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
        sceneNode.entities = scene.entities
        sceneNode.graphs = scene.graphs
        
        // Set the scale mode to scale to fit the window
        sceneNode.scaleMode = .aspectFill
        
        // Present the scene
        if let view = self.view as! SKView? {
          view.presentScene(sceneNode)
          
          view.ignoresSiblingOrder = true
          
          view.showsFPS = true
          view.showsNodeCount = true
//          view.showsPhysics = true
        }
        
        sceneNode.multiplayerNetworking = MultiplayerNetworking()
        self.setupNetworkingNotifcations(delegate: sceneNode)
      }
    }
    
    self.viewDidLayoutSubviews()
  }
  
  private func setupNetworkingNotifcations(delegate: MultiplayerNetworkingProtocol) {
    let networking = MultiplayerNetworking()
    networking.delegate = delegate
    NotificationCenter.Publisher(center: .default, name: .startMatchmaking, object: nil)
      .sink(receiveValue: { notification in
        GameKitHelper.shared.findMatch(vc: self, delegate: networking) { vc in
          
        }
      })
      .store(in: &subscriptions)
  }
}
