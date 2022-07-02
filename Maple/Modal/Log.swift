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
    
    public func stringRep() -> String {
        return "\(self.type.rawValue)[\(self.bundle)] @(\(self.time)) - \(self.log)"
    }
}

enum LogType: String {
    case error = "ERROR "
    case warning = "WARNING "
    case normal = ""
}
