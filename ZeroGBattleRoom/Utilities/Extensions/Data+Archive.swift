//
//  Data+Archive.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation

extension Data {
  static func archiveUnsafeBytes<T>(object:T) -> Data {
    var mutableObject = object

    return Data(bytes: &mutableObject, count: MemoryLayout<T>.stride)
  }

  static func unarchiveUnsafeBytes<T>(data: Data) -> T {
    return data.withUnsafeBytes { $0.load(as: T.self) }
  }
  
  static func archiveJSON<T: Encodable>(object:T) -> Data {
    return try! JSONEncoder().encode(object)
  }

  static func unarchiveJSON<T: Decodable>(data: Data) -> T {
    return try! JSONDecoder().decode(T.self, from: data)
  }
}
