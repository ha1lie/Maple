//
//  MapleLogController.swift
//  Maple
//
//  Created by Hallie on 6/26/22.
//

import Foundation

class MapleLogController: ObservableObject {
    
    static let shared: MapleLogController = MapleLogController()
    
    @Published var logs: [Log]
    
    init() {
        self.logs = []
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(logObserver(notification:)), name: NSNotification.Name(rawValue: "maple.log"), object: nil)
    }
    
    /// Observer run when a notification from DistributedNotificationCenter is received indicating a new log
    /// - Parameter notification: Notification object which triggered this
    @objc private func logObserver(notification: Notification) {
        if let stuff = notification.object as? String {
            let parts = stuff.components(separatedBy: "+++")
            if parts.count == 2 {
                #if DEBUG
                print("+TIME [\(parts[0]) - \(parts[1])")
                #endif
                DispatchQueue.main.async {
                    self.logs.append(Log(parts[1], forBundle: parts[0], atTime: "TIME", withType: .normal)) //TODO: Make this parse correctly for type and time
                }
            } else {
                DispatchQueue.main.async {
                    self.logs.append(Log("Failed to parse Log object from log observer: Wrong part count", forBundle: "dev.halz.Maple", atTime: "TIME", withType: .error))
                }
            }
        } else {
            DispatchQueue.main.async {
                self.logs.append(Log("Failed to parse Log object from log observer", forBundle: "dev.halz.Maple", atTime: "TIME", withType: .error))
            }
        }
    }
    
    /// Make a Log objection from String
    /// - Parameters:
    ///   - str: String of the Log
    ///   - bundle: The bundle which owns this Log
    /// - Returns: Log object
    private func makeLog(fromString str: String, inBundle bundle: String) -> Log {
        var value = str
        var type: LogType = .normal
        
        if str.prefix(upTo: str.index(str.startIndex, offsetBy: 5)).uppercased() == "ERROR" {
            value = String(str.suffix(from: str.index(str.startIndex, offsetBy: 6)))
            type = .error
        } else if str.prefix(upTo: str.index(str.startIndex, offsetBy: 7)).uppercased() == "WARNING" {
            value = String(str.suffix(from: str.index(str.startIndex, offsetBy: 8)))
            type = .warning
        }
        
        return Log(value, forBundle: bundle, atTime: "TIME", withType: type)
    }
    
    /// Adds a log from the app 
    /// - Parameter log: Log to display to the user
    public func local(log: String) {
        #if DEBUG
        print("+TIME [dev.halz.Maple] - \(log)")
        #endif
        DispatchQueue.main.async {
            self.logs.append(self.makeLog(fromString: log, inBundle: "dev.halz.Maple"))
        }
    }
}
