//
//  MultiplayerNetworking+GameKitHelper.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameKit

extension MultiplayerNetworking: GameKitHelperDelegate {
  public func matchStarted() {
    print("Match has started successfully")
    self.gameState = self.recievedAllRandomNumbers ? .waitingForStart : .waitingForRandomNumber
    
    self.sendRandomNumber()
    self.tryStartGame()
  }
  
  public func matchEnded() {
    print("Match ended")
  }
  
  func match(_ match: GKMatch, didReceive data: Data, from player: GKPlayer) {
//    let message: Message = data.withUnsafeBytes { $0.load(as: Message.self) }
    
    let message: UnifiedMessage = Data.unarchiveJSON(data: data)
    
    switch message.type {
    case .randomeNumber:
      self.handleRandomNumber(message, player: player)
    case .gameBegin:
      self.handleGameBegin(message)
    case .move:
      self.handleMove(message)
    case .impacted:
      self.handleImpacted(message, player: player)
    case .moveResource:
      self.handleMoveResource(message)
    case .grabResource:
      self.handleGrabResource(message, player: player)
    case .gameOver:
      self.handleGameOver(message)
    case .snapshot:
      self.handleSnapshot(message)
    }
  }
  
}

extension MultiplayerNetworking {
  
  // MARK: - Handler Methods
  
  private func handleRandomNumber(_ snapshot: UnifiedMessage, player: GKPlayer) {
    let randomNumber = snapshot.randomNumber!
        
    print("Recieved random number: \(randomNumber)")
    
    var tie = false
    if randomNumber == self.ourRandomNumber {
      print("Tie")
      tie = true
      self.ourRandomNumber = Double.random(in: 0.0...1000.0)
      self.sendRandomNumber()
    } else {
      self.processReceivedRandomNumber(randomNumberDetails: [
        DetailsKeys.playerKey: player,
        DetailsKeys.randomNumberKey: randomNumber])
    }
    
    if self.recievedAllRandomNumbers {
      self.isPlayer1 = self.isLocalPlayerHost()
    }

    if !tie && self.recievedAllRandomNumbers {
      if self.gameState == .waitingForRandomNumber {
        self.gameState = .waitingForStart
      }
      self.tryStartGame()
    }
  }
  
  private func handleGameBegin(_ snapshot: UnifiedMessage) {
    print("Begin game message received")
    self.gameState = .active
    
    self.delegate?.setCurrentPlayerAt(index: self.indicesForPlayers.local)
    self.processPlayerAliases()
  }
  
  private func handleMove(_ snapshot: UnifiedMessage) {
    let elements = snapshot.elements!
    
    guard elements.count > 0 else { fatalError("Error: Elements array is empty.") }
    
    let playerGroup = elements[0]
    guard playerGroup.count > 0 else { fatalError("Error: Player group array is empty.")}
    
    print("Move message received")
    self.delegate?.movePlayerAt(index: self.indicesForPlayers.remote,
                                position: playerGroup[0].position,
                                direction: playerGroup[0].vector)
  }
  
  private func handleImpacted(_ snapshot: UnifiedMessage, player: GKPlayer) {
    print("Impacted message received")
    self.delegate?.impactPlayer(player: player)
  }
  
  private func handleMoveResource(_ snapshot: UnifiedMessage) {
    guard let elements = snapshot.elements,
      elements.count > 0,
      let resoureceGroup = elements.first,
      resoureceGroup.count > 0 else { fatalError("Error: Element group array is empty.")}
    guard let index = snapshot.resourceIndex else { fatalError("Error: Resource index is missing.") }
    
    print("Resource move message received")
    self.delegate?.moveResourceAt(index: index,
                                  position: resoureceGroup[0].position,
                                  vector: resoureceGroup[0].vector)
  }
  
  private func handleGrabResource(_ snapshot: UnifiedMessage, player: GKPlayer) {
    guard let index = snapshot.resourceIndex else { fatalError("Error: Resource index is missing.") }
    guard let playerIndex = snapshot.playerIndex else { fatalError("Error: Player index is missing.") }
    
    print("Grab message received")
    self.delegate?.grabResourceAt(index: index, playerIndex: playerIndex, player: player)
  }
  
  private func handleGameOver(_ snapshot: UnifiedMessage) {
    let player1Won = snapshot.player1Won!
    
    print("Game over message received - Host \(player1Won ? "Won" : "Lost" )")
    self.delegate?.gameOver(player1Won: player1Won)
  }
  
  private func handleSnapshot(_ snapshot: UnifiedMessage) {
    let elements = snapshot.elements!
    let expectdNumberOfElements = MultiplayerNetworkingSnapshot.GroupIndecies.allCases.count
    guard elements.count == expectdNumberOfElements else {
      fatalError("Error: Missing Elements: \(elements)")
    }
    
    print("Snapshot received")
    
    let playerGroup = elements[MultiplayerNetworkingSnapshot.GroupIndecies.players.rawValue]
    guard playerGroup.count > 0 else {
      fatalError("Error: Missing players: \(playerGroup)")
    }
    
    for (idx, player) in playerGroup.enumerated() {
      guard idx != self.indicesForPlayers.local else {
        print("Skip remote player sync.")
        continue
      }
      
      self.delegate?.syncPlayerAt(index: idx,
                                  position: player.position,
                                  vector: player.vector)
    }
    
    guard !self.isLocalPlayerHost() else {
      print("Only update game elements for client devices.")
      return
    }
    
    let resourceGroup = elements[MultiplayerNetworkingSnapshot.GroupIndecies.resources.rawValue]
    guard resourceGroup.count > 0 else {
      fatalError("Error: Missing resources: \(resourceGroup)")
    }
    
    // Spawn resources as needed
    self.delegate?.syncResources(resources: resourceGroup)
    
    for (idx, resource) in resourceGroup.enumerated() {
      self.delegate?.syncResourceAt(index: idx,
                                    position: resource.position,
                                    vector: resource.vector)
    }
  }
  
  private func isLocalPlayerHost() -> Bool {
    guard let firstPlayer = self.orderOfPlayers.first,
      let player = firstPlayer[DetailsKeys.playerKey] as? GKPlayer else { return false }
    
    print("I'm player \(player == GKLocalPlayer.local ? 1 : 2)")
    return player == GKLocalPlayer.local
  }
}

extension MultiplayerNetworking {
  private func tryStartGame() {
    if self.isPlayer1 && self.gameState == .waitingForStart {
      self.gameState = .active
      
      self.sendGameBegin()
      
      self.delegate?.setCurrentPlayerAt(index: 0)
      self.processPlayerAliases()
      
      MultiplayerNetworkingSnapshot.shared.includeResources = true
    }
  }
}
