//
//  MultiplayerNetworking+GameKitHelper.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import GameKit

extension MulitplayerNetworking: GameKitHelperDelegate {
  
  // MARK: - Conform to GameKitHelperDelegate
  
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
    let message: Message = Data.unarchive(data: data)
    
    switch message.type {
    case .randomeNumber:
      self.handleRandomNumberMessage(data: data, player: player)
    case .gameBegin:
      self.handleGameBeginMessage()
    case .move:
      self.handleMoveMessage(data: data)
    case .gameOver:
      self.handleGameOver(data: data)
    case .snapshot:
      self.handleSnapshot(data: data)
    }
  }
  
  private func handleSnapshot(data: Data) {
    let snapshotMessage: MessageSnapshot = Data.unarchive(data: data)
//      let expectdNumberOfElements = MultiplayerNetworkingSnapshot.ElementIndex.allCases.count
//      guard snapshotMessage.elements.count == expectdNumberOfElements else { return }
      guard snapshotMessage.elements.count == 2 else { return }
      
      let host = snapshotMessage.elements[0]
      let client = snapshotMessage.elements[1]
      
      print("Snapshot received")
      
      self.delegate?.movePlayerAt(index: 0, position: host.0, direction: host.1)
      self.delegate?.movePlayerAt(index: 1, position: client.0, direction: client.1)
  }
  
  private func handleGameOver(data: Data) {
    print("Game over message received")
  }
  
  private func handleMoveMessage(data: Data) {
    print("Move game message received")
    let moveMessage: MessageMove = Data.unarchive(data: data)
    
    self.delegate?.movePlayerAt(index: self.indicesForPlayers.remote,
                                position: moveMessage.position,
                                direction: moveMessage.vector)
  }
  
  private func handleGameBeginMessage() {
    print("Begin game message received")
    self.gameState = .active
    
    self.delegate?.setCurrentPlayerAt(index: self.indicesForPlayers.local)
  }
  
  private func handleRandomNumberMessage(data: Data, player: GKPlayer) {
    let randomMessage: MessageRandomNumber = Data.unarchive(data: data)
        
    print("Recieved random number: \(randomMessage.randomNumber)")
    
    var tie = false
    if randomMessage.randomNumber == self.ourRandomNumber {
      print("Tie")
      tie = true
      self.ourRandomNumber = Double.random(in: 0.0...1000.0)
      self.sendRandomNumber()
    } else {
      self.processReceivedRandomNumber(randomNumberDetails: [
        MulitplayerNetworking.playerKey: player,
        MulitplayerNetworking.randomNumberKey: randomMessage.randomNumber])
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
  
  private func isLocalPlayerHost() -> Bool {
    guard let firstPlayer = self.orderOfPlayers.first,
      let player = firstPlayer[MulitplayerNetworking.playerKey] as? GKPlayer else { return false }
    
    print("I'm player \(player == GKLocalPlayer.local ? 1 : 2)")
    return player == GKLocalPlayer.local
  }
}

extension MulitplayerNetworking {
  private func tryStartGame() {
    if self.isPlayer1 && self.gameState == .waitingForStart {
      self.gameState = .active
      self.sendGameBegin()
      
      self.delegate?.setCurrentPlayerAt(index: 0)
      
      MultiplayerNetworkingSnapshot.shared.isSendingSnapshots = true
    }
  }
}
