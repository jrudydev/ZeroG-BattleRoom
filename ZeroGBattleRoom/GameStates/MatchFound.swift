//
//  MatchFound.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 5/11/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameplayKit
import Combine


class MatchFound: GKState {
  unowned let scene: GameScene
  
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  private var subscriptions = Set<AnyCancellable>()
  
  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
    
    self.timer
      .sink { _ in
        guard let countDownLabel = self.scene.childNode(withName: AppConstants.ComponentNames.matchFoundCountDownLabel) as? SKLabelNode,
          let secondsText = countDownLabel.text,
          let seconds = Int(secondsText) else { return }
        
        guard seconds > 0 else { self.scene.gameState.enter(Playing.self); return }
        
        countDownLabel.text = "\(seconds - 1)"
      }
      .store(in: &subscriptions)
  }
  
  override func didEnter(from previousState: GKState?) {
    self.scene.multiplayerNetworking?.resetPlayerOrder()
    
    let background = SKShapeNode(rectOf: UIScreen.main.bounds.size)
    background.name = AppConstants.ComponentNames.menuBackgroundName
    background.fillColor = UIColor.black.withAlphaComponent(20.0)
    background.strokeColor = UIColor.black
    background.zPosition = 100
    self.scene.addChild(background)
    
    let vsLabel = SKLabelNode(text: "vs")
    vsLabel.name = AppConstants.ComponentNames.matchFoundVSLabel
    vsLabel.fontSize = 30.0
    vsLabel.zPosition = SpriteZPosition.menuLabel.rawValue
    self.scene.addChild(vsLabel)
    
    let startsInLabel = SKLabelNode(text: "Game starts in...")
    startsInLabel.name = AppConstants.ComponentNames.matchFoundStartsInLabel
    startsInLabel.fontSize = 30.0
    startsInLabel.position = CGPoint(x: 0.0, y: -250.0)
    startsInLabel.zPosition = SpriteZPosition.menuLabel.rawValue
    self.scene.addChild(startsInLabel)
    
    let counDownLabel = SKLabelNode(text: "5")
    counDownLabel.name = AppConstants.ComponentNames.matchFoundCountDownLabel
    counDownLabel.fontSize = 30.0
    counDownLabel.position = CGPoint(x: 0.0, y: -300.0)
    counDownLabel.zPosition = SpriteZPosition.menuLabel.rawValue
    self.scene.addChild(counDownLabel)
  
    let player1Alias = self.scene.getPlayerAliasAt(index: 0)
    let player1Label = SKLabelNode(text: player1Alias)
    player1Label.name = AppConstants.ComponentNames.matchFoundPlayer1Label
    player1Label.fontSize = 30.0
    player1Label.position = CGPoint(x: 0.0, y: 100.0)
    player1Label.zPosition = SpriteZPosition.menuLabel.rawValue
    self.scene.addChild(player1Label)
    
    let player2Alias = self.scene.getPlayerAliasAt(index: 1)
    let player2Label = SKLabelNode(text: player2Alias)
    player2Label.name = AppConstants.ComponentNames.matchFoundPlayer2Label
    player2Label.fontSize = 30.0
    player2Label.position = CGPoint(x: 0.0, y: -100.0)
    player2Label.zPosition = SpriteZPosition.menuLabel.rawValue
    self.scene.addChild(player2Label)
  }
  
  override func willExit(to nextState: GKState) {
    self.scene
      .childNode(withName: AppConstants.ComponentNames.menuBackgroundName)?
      .removeFromParent()
    self.scene
      .childNode(withName: AppConstants.ComponentNames.matchFoundVSLabel)?
      .removeFromParent()
    self.scene
      .childNode(withName: AppConstants.ComponentNames.matchFoundStartsInLabel)?
      .removeFromParent()
    self.scene
      .childNode(withName: AppConstants.ComponentNames.matchFoundCountDownLabel)?
      .removeFromParent()
    self.scene
      .childNode(withName: AppConstants.ComponentNames.matchFoundPlayer1Label)?
      .removeFromParent()
    self.scene
      .childNode(withName: AppConstants.ComponentNames.matchFoundPlayer2Label)?
      .removeFromParent()
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Playing.Type
  }
}
