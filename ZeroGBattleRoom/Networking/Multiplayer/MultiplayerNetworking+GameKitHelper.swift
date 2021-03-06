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
    self.delegate?.matchEnded()
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
      try? self.handleMove(message)
//    case .impacted:
//      self.handleImpacted(message)
//    case .wallHit:
//      self.handleWallHit(message)
//    case .moveResource:
//      self.handleMoveResource(message)
//    case .grabResource:
//      self.handleGrabResource(message)
//    case .assignResource:
//      self.handleAssignResource(message)
    case .gameOver:
      self.handleGameOver(message)
    case .snapshot:
      try? self.handleSnapshot(message)
    }
  }
  
}

extension MultiplayerNetworking {
  
  // MARK: - Handler Methods
  
  private func handleRandomNumber(_ message: UnifiedMessage, player: GKPlayer) {
    let randomNumber = message.randomNumber!
        
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
  
  private func handleGameBegin(_ message: UnifiedMessage) {
    print("Begin game message received")
    self.gameState = .active
    
    self.delegate?.setCurrentPlayerAt(index: self.indicesForPlayers.local)
    self.processPlayerAliases()
  }
  
  private func handleMove(_ message: UnifiedMessage) throws {
    guard let elements = message.elements else {
      throw(NetworkError.missingElements(message: "Missing elements\(message)")) }
    guard let playerGroup = elements.first else {
      throw(NetworkError.missingGroup(message: "Missing players group: \(elements)")) }
    guard let playerSnap = playerGroup.first else {
      throw(NetworkError.playerNotFound(message: "Player not found: \(playerGroup)")) }
    guard let wasLaunch = message.boolValue else {
      throw(NetworkError.playerNotFound(message: "Launch info missing: \(message)")) }
    
    print("Move message received")
    self.delegate?.movePlayerAt(index: self.indicesForPlayers.remote,
                                position: playerSnap.position,
                                rotation: playerSnap.rotation,
                                velocity: playerSnap.velocity,
                                angularVelocity: playerSnap.angularVelocity,
                                wasLaunch: wasLaunch)
  }
  
//  private func handleMoveResource(_ message: UnifiedMessage) {
//    guard let elements = message.elements,
//      elements.count > 0,
//      let resoureceGroup = elements.first,
//      resoureceGroup.count > 0 else { fatalError("Error: Element group array is empty.")}
//    guard let index = message.resourceIndex else { fatalError("Error: Resource index is missing.") }
//
//    print("Resource move message received")
//    self.delegate?.moveResourceAt(index: index,
//                                  position: resoureceGroup[0].position,
//                                  rotation: resoureceGroup[0].rotation,
//                                  velocity: resoureceGroup[0].velocity,
//                                  angularVelocity: resoureceGroup[0].angularVelocity)
//  }
//
//  private func handleImpacted(_ message: UnifiedMessage) {
//    guard let senderIndex = message.senderIndex else { fatalError("Error: Player index is missing.") }
//
//    print("Impacted message received")
//    self.delegate?.impactPlayerAt(senderIndex: senderIndex)
//  }
//
//  private func handleWallHit(_ message: UnifiedMessage) {
//    guard let index = message.resourceIndex else { fatalError("Error: Wall index is missing.") }
//    guard let boolValue = message.boolValue else { fatalError("Error: Occupied bool is missing.") }
//
//    print("Impacted message received")
//    self.delegate?.syncWallAt(index: index, isOccupied: boolValue)
//  }
//
//  private func handleGrabResource(_ message: UnifiedMessage) {
//    guard let index = message.resourceIndex else { fatalError("Error: Resource index is missing.") }
//    guard let playerIndex = message.playerIndex else { fatalError("Error: Player index is missing.") }
//    guard let senderIndex = message.senderIndex else { fatalError("Error: Sender index is missing.") }
//
//    print("Grab message received")
//    self.delegate?.grabResourceAt(index: index,
//                                  playerIndex: playerIndex,
//                                  senderIndex: senderIndex)
//  }
//
//  private func handleAssignResource(_ message: UnifiedMessage) {
//    guard let index = message.resourceIndex else { fatalError("Error: Resource index is missing.") }
//    guard let playerIndex = message.playerIndex else { fatalError("Error: Player index is missing.") }
//
//    print("Grab message received")
//    self.delegate?.assignResourceAt(index: index, playerIndex: playerIndex)
//  }
  
  private func handleGameOver(_ message: UnifiedMessage) {
    guard let player1Won = message.boolValue else { fatalError("Error: Bool value is missing." ) }
    
    print("Game over message received - Host \(player1Won ? "Won" : "Lost" )")
    self.delegate?.gameOver(player1Won: player1Won)
  }
  
  private func handleSnapshot(_ message: UnifiedMessage) throws {
    guard let elements = message.elements else {
      throw(NetworkError.missingElements(message: "Missing elements"))
    }
    
    let expectdElementGroups = SnapshotManager.GroupIndecies.allCases.count
    guard  elements.count == expectdElementGroups else {
      throw(NetworkError.missingElements(message: "Incomplete group data: \(elements)"))
    }
    
    let playerGroup = elements[SnapshotManager.GroupIndecies.players.rawValue]
    guard playerGroup.count > 0 else {
      throw(NetworkError.playerNotFound(message: "Missing players group: \(playerGroup)"))
    }
    
    // NOTE: Update remote players only
    for (idx, playerSnap) in playerGroup.enumerated() {
      guard idx != self.indicesForPlayers.local else { continue }

      self.delegate?.syncPlayerAt(index: idx,
                                  position: playerSnap.position,
                                  rotation: playerSnap.rotation,
                                  velocity: playerSnap.velocity,
                                  angularVelocity: playerSnap.angularVelocity,
                                  resourceIndecies: playerSnap.resourceIndecies)
    }
    
    // NOTE: Only the host is expected to send the resource data
    let resourceGroup = elements[SnapshotManager.GroupIndecies.resources.rawValue]
    if resourceGroup.count > 0 {
      // Spawn resources as needed
      self.delegate?.syncResources(resources: resourceGroup)
      
      // Recovery mechanizm that will re-sync all player resource ownership with the host
      self.delegate?.syncPlayerResources(players: playerGroup)

      for (idx, resourceSnap) in resourceGroup.enumerated() {
        self.delegate?.syncResourceAt(index: idx,
                                      position: resourceSnap.position,
                                      rotation: resourceSnap.rotation,
                                      velocity: resourceSnap.velocity,
                                      angularVelocity: resourceSnap.angularVelocity)
      }
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
      
      SnapshotManager.shared.includeResources = true
    }
  }
}
