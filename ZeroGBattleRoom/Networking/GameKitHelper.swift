//
//  GameKitHelper.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameKit

class GameKitHelper: NSObject {
  private override init() {}
  
  static let shared = GameKitHelper()
  
  var match: GKMatch?
  var playersDict = [String: GKPlayer]()
  
  private var delegate: GameKitHelperDelegate?
  
  private var isAuthenticated = false
  private var matchStarted = false
  
  func gameCenterAuthPlayer(_ completion: @escaping (UIViewController) -> Void) {
    let localPlayer = GKLocalPlayer.local
    
    localPlayer.authenticateHandler = { view, error in
      if let error = error {
        print("\(error.localizedDescription)")
        self.isAuthenticated = false
        return
      }
      
      guard let view = view else {
        print("Authentication \(localPlayer.isAuthenticated ? "success." : "failure.")")
        self.isAuthenticated = localPlayer.isAuthenticated
        return
      }
      
      completion(view)
    }
  }
  
  func findMatch(vc: UIViewController,
                 delegate: GameKitHelperDelegate,
                 completion: (GKMatchmakerViewController?) -> Void) {
    guard self.isAuthenticated else { return }
    
    self.matchStarted = false
    self.match = nil
    self.delegate = delegate
    
    let request = GKMatchRequest()
    request.minPlayers = 2
    request.maxPlayers = 2
    
    let mmvc = GKMatchmakerViewController(matchRequest: request)
    mmvc?.matchmakerDelegate = self
    if mmvc != nil {
      vc.present(mmvc!, animated: true)
    }
    
    completion(mmvc)
  }
  
  private func foundPlayers() {
    guard let match = self.match else { return }
    
    print("Found \(String(describing: match.players.count)) players")
    
    for player in match.players {
      print("Player found: \(player.alias)")
      self.playersDict[player.gamePlayerID] = player
    }
    self.playersDict[GKLocalPlayer.local.gamePlayerID] = GKLocalPlayer.local
    
    self.matchStarted = true
    self.delegate?.matchStarted()
  }
}

extension GameKitHelper: GKMatchmakerViewControllerDelegate {
  func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
    viewController.dismiss(animated: true)
  }
  
  func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                didFailWithError error: Error) {
    viewController.dismiss(animated: true)
    print("\(error.localizedDescription)")
  }
  
  func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                didFind match: GKMatch) {
    viewController.dismiss(animated: true)
    
    self.match = match
    match.delegate = self
    
    if !self.matchStarted && match.expectedPlayerCount == 0 {
      print("Ready to start match")
      foundPlayers()
    }
  }
}

extension GameKitHelper: GKMatchDelegate {
  func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
    guard match == self.match else { return }
    
    self.delegate?.match(match, didReceive: data, from: player)
  }
  
  func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
    guard match == self.match else { return }
    
    switch state {
    case .connected:
      print("Player connected!")
      
      if !self.matchStarted && match.expectedPlayerCount == 0 {
        print("Ready to start match!")
        foundPlayers()
      }
    case .disconnected:
      print("Player disconnected!")
      self.matchStarted = false
      
      delegate?.matchEnded()
    default: break
    }
  }
  
  func match(_ match: GKMatch, didFailWithError error: Error?) {
    guard match == self.match else { return }
    
    if let error = error {
      print("Match failed with error: \(error.localizedDescription)")
    }
  
    self.matchStarted = false
    delegate?.matchEnded()
  }
}


