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
  public func matchStarted() {
    print("Match has started successfully")
    self.gameState = self.recievedAllRandomNumbers ? .waitingForStart : .waitingForRandomNumber
    
    self.sendRandomNumber()
    self.tryStartGame()
  }
  
  private func sendRandomNumber() {
    var message = MessageRandomNumber(mesage: Message(type: .randomeNumber),
                                      randomNumber: self.ourRandomNumber)
    let data = Data(bytes: &message, count: MemoryLayout<MessageRandomNumber>.stride)
    self.sendData(data)
  }
  
  private func sendGameBegin() {
    var message = MessageGameBegin(mesage: Message(type: .gameBegin))
    
    let data = Data(bytes: &message, count: MemoryLayout<MessageGameBegin>.stride)
    self.sendData(data)
  }
  
  private func tryStartGame() {
    if self.isPlayer1 && self.gameState == .waitingForStart {
      self.gameState = .active
      self.sendGameBegin()
      
      self.delegate?.setCurrentPlayer(index: 0)
    }
  }
  
  public func matchEnded() {
    print("Match ended")
  }
  
  func match(_ match: GKMatch, didReceive data: Data, from player: GKPlayer) {
    let message: Message = Data.unarchive(data: data)
    
    if case .randomeNumber = message.type {
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
        self.isPlayer1 = self.isLocalPlayerPlayer1
      }
  
      if !tie && self.recievedAllRandomNumbers {
        if self.gameState == .waitingForRandomNumber {
          self.gameState = .waitingForStart
        }
        self.tryStartGame()
      }
    }
    
    if case .gameBegin = message.type {
      print("Begin game message received")
      self.gameState = .active
    }
    
    if case .move = message.type {
      print("Move game message received")
      let moveMessage: MessageMove = Data.unarchive(data: data)
      
      
    }
    
    if case .gameOver = message.type {
      print("Game over message received")
    }
  }
}
