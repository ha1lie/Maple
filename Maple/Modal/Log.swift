//
//  Log.swift
//  Maple
//
//  Created by Hallie on 6/26/22.
//

import Foundation

struct Log: Equatable, Hashable {
    var bundle: String
    var log: String
    var time: String
    var type: LogType
    
    init(_ log: String, forBundle bundle: String = "", atTime time: String = "", withType type: LogType = .normal) {
        self.log = log
        self.bundle = bundle
        self.time = time
        self.type = type
    }
}

enum LogType {
    case error
    case warning
    case normal
}
