//
//  MultiplayerNetworking.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit


class MulitplayerNetworking {
  static let playerKey = "PlayerKey"
  static let randomNumberKey = "RandomNumberKey"
  
  enum GameState: Int {
    case waitingForMatch
    case waitingForRandomNumber
    case waitingForStart
    case active
    case done
  }
  
  var gameState: GameState = .waitingForMatch
  
  var ourRandomNumber = Double.random(in: 0.0...1000.0)
  private var allRandomNumbersReceived: Bool {
    guard let match = GameKitHelper.shared.match else { return false }
    
    return self.orderOfPlayers.count == match.players.count + 1
  }
  
  var orderOfPlayers: [[String: Any]]
  var recievedAllRandomNumbers = false
  var isPlayer1 = false
  
  var indicesForPlayers: (local: Int, remote: Int ) {
    return self.isPlayer1 ? (local: 0, remote: 1) :  (local: 1, remote: 0)
  }
  
  var delegate: MultiplayerNetworkingProtocol?
  
  init() {
    self.orderOfPlayers = [[
      MulitplayerNetworking.playerKey: GKLocalPlayer.local,
      MulitplayerNetworking.randomNumberKey: self.ourRandomNumber]]
  }
  
  func sendData(_ data: Data, mode: GKMatch.SendDataMode = .reliable) {
    guard let match = GameKitHelper.shared.match else { return }
    
    do {
      try match.send(data, to: match.players, dataMode: mode)
    } catch {
      print("Error sending data: \(error.localizedDescription)")
      self.matchEnded()
    }
  }
}

extension MulitplayerNetworking {
  func sendMove(start pos: CGPoint, direction: CGVector) {
    var message = MessageMove(mesage: Message(type: .move),
                              position: pos,
                              vector: direction)
    
    let data = Data(bytes: &message, count: MemoryLayout<MessageMove>.stride)
    self.sendData(data)
  }
  
  func sendSnapshot(_ elements: [(CGPoint, CGVector)]) {
    var message = MessageSnapshot(message: Message(type: .snapshot),
                                  elements: elements)
    
    let data = Data(bytes: &message, count: MemoryLayout<MessageSnapshot>.stride)
    self.sendData(data, mode: .unreliable)
  }
  
  func sendRandomNumber() {
    var message = MessageRandomNumber(mesage: Message(type: .randomeNumber),
                                      randomNumber: self.ourRandomNumber)
    let data = Data(bytes: &message, count: MemoryLayout<MessageRandomNumber>.stride)
    self.sendData(data)
  }
  
  func sendGameBegin() {
    var message = MessageGameBegin(mesage: Message(type: .gameBegin))
    
    let data = Data(bytes: &message, count: MemoryLayout<MessageGameBegin>.stride)
    self.sendData(data)
  }
}

extension MulitplayerNetworking {
  func processReceivedRandomNumber(randomNumberDetails: [String: Any]) {
    guard randomNumberDetails.count > 0 else {
      print("Error: Expected random details missing.")
      return
    }
    
    let contains = self.orderOfPlayers.contains { details -> Bool in
      let detailsPlayer = details[MulitplayerNetworking.playerKey] as? GKPlayer
      let detailsNumber = details[MulitplayerNetworking.randomNumberKey] as? Double
      let player = randomNumberDetails[MulitplayerNetworking.playerKey] as? GKPlayer
      let randomNumber = randomNumberDetails[MulitplayerNetworking.randomNumberKey] as? Double

      return detailsPlayer == player && detailsNumber == randomNumber
    }
    
    if contains {
      let index = self.orderOfPlayers.firstIndex { details -> Bool in
        let detailsPlayer = details[MulitplayerNetworking.playerKey] as? GKPlayer
        let detailsNumber = details[MulitplayerNetworking.randomNumberKey] as? Double
        let player = randomNumberDetails[MulitplayerNetworking.playerKey] as? GKPlayer
        let randomNumber = randomNumberDetails[MulitplayerNetworking.randomNumberKey] as? Double
        
        return detailsPlayer == player && detailsNumber == randomNumber
      }
      self.orderOfPlayers.remove(at: index!)
    }
    
    self.orderOfPlayers.append(randomNumberDetails)
    self.orderOfPlayers.sort { first, second in
      let firstNumber = (first[MulitplayerNetworking.randomNumberKey] as? Double)!
      let secondNumber = (second[MulitplayerNetworking.randomNumberKey] as? Double)!
    
      return firstNumber > secondNumber
    }
    
    if self.allRandomNumbersReceived {
      self.recievedAllRandomNumbers = true
    }
  }
  
  private func indexForLocal(player: GKPlayer) -> Int {
    return self.orderOfPlayers.firstIndex { details -> Bool in
      let detailsPlayer = (details[MulitplayerNetworking.playerKey] as? GKPlayer)!
      
      return player == detailsPlayer
    }!
  }
}


// MARK: - Messanging Objects

extension MulitplayerNetworking {
  enum MessageType: Int {
    case randomeNumber
    case gameBegin
    case move
    case gameOver
    case snapshot
  }
  
  struct Message {
    let type: MessageType
  }
  
  struct MessageRandomNumber {
    let mesage: Message
    let randomNumber: Double
  }
  
  struct MessageGameBegin {
    let mesage: Message
  }
  
  struct MessageMove {
    let mesage: Message
    let position: CGPoint
    let vector: CGVector
  }
  
  struct MessageGameOver {
    let message: Message
    let player1Won: Bool
  }
  
  struct MessageSnapshot {
    let message: Message
    let elements: [(CGPoint, CGVector)]
  }
}
