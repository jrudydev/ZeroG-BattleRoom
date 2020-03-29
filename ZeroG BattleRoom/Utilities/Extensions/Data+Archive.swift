//
//  Data+Archive.swift
//  SpaceMonkies
//
//  Created by Rudy Gomez on 3/28/20.
//  Copyright © 2020 JRudy Gaming. All rights reserved.
//

import Foundation

extension Data {
  static func archive<T>(object:T) -> Data {
    var mutableObject = object
    return Data(bytes: &mutableObject, count: MemoryLayout<T>.stride)
  }

  static func unarchive<T>(data: Data) -> T {
//    guard data.count == MemoryLayout<T>.stride else {
//      fatalError("Error when unarchiving data.")
//    }

    return data.withUnsafeBytes { $0.load(as: T.self) }
  }
}
