//
//  MultiplayerNetworkingError.swift
//  ZeroG BattleRoom
//
//  Created by Rudy Gomez on 4/25/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation


enum NetworkError: LocalizedError {
  case missingElements(message: String)
  case missingGroup(message: String)
  case playerNotFound(message: String)
  case resourcesNotFound(message: String)
  
  var errorDescription: String? {
    switch self {
    case let .missingElements(message),
         let .missingGroup(message),
         let .playerNotFound(message),
         let .resourcesNotFound(message):
      return message
    }
  }
}
