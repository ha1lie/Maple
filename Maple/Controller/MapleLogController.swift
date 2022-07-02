//
//  MapleLogController.swift
//  Maple
//
//  Created by Hallie on 6/26/22.
//

import Foundation

class MapleLogController: ObservableObject {
    
    static let shared: MapleLogController = MapleLogController()
    
    private static let logFolderLocation: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/.logs")
    private static let logFileLocation: URL = MapleLogController.logFolderLocation.appendingPathComponent("log.log")
    
    private static var formatter: DateFormatter {
        if privateFormatter == nil {
            privateFormatter = DateFormatter()
            privateFormatter?.timeStyle = .medium
        }
        return privateFormatter!
    }
    
    private static var privateFormatter: DateFormatter? = nil
    
    @Published var logs: [Log]
    
    init() {
        self.logs = []
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(logObserver(notification:)), name: NSNotification.Name(rawValue: "maple.log"), object: nil, suspensionBehavior: .deliverImmediately)
        
        if !FileManager.default.fileExists(atPath: MapleLogController.logFolderLocation.path) {
            try? FileManager.default.createDirectory(at: MapleLogController.logFolderLocation, withIntermediateDirectories: true)
        }
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
                self.addLog(Log(parts[1], forBundle: parts[0], atTime: MapleLogController.formatter.string(from: Date.now), withType: .normal))
            } else {
                self.addLog(Log("Failed to parse Log object from log observer: Wrong part count", forBundle: "dev.halz.Maple", atTime: "TIME", withType: .error))
            }
        } else {
            self.addLog(Log("Failed to parse Log object from log observer", forBundle: "dev.halz.Maple", atTime: "TIME", withType: .error))
        }
    }
    
    /// Adds a log to memory, as well as on disk
    /// - Parameter log: Log object to add
    private func addLog(_ log: Log) {
        DispatchQueue.main.async {
            self.logs.append(log)
        }
        
        if !FileManager.default.fileExists(atPath: MapleLogController.logFileLocation.path) {
            FileManager.default.createFile(atPath: MapleLogController.logFileLocation.path, contents: "".data(using: .utf8))
        }
        
        if let logData = (log.stringRep() + "\n").data(using: .utf8) {
            // Thanks to https://stackoverflow.com/a/40687742 for this... otherwise we'd be reading this file too much for our own good
            if let logHandler = FileHandle(forWritingAtPath: MapleLogController.logFileLocation.path) {
                defer {
                    try? logHandler.close()
                }
                let _ = try? logHandler.seekToEnd()
                try? logHandler.write(contentsOf: logData)
            }
        }
    }
    
    /// Copies the current log file to a chosen location
    /// - Parameter loc: Location to copy the log file to
    public func exportLogFile() -> String {
        if let contents = FileManager.default.contents(atPath: MapleLogController.logFileLocation.path) {
            if let read = String(data: contents, encoding: .utf8) {
                return read
            }
        }
        return "Failed to export the actual log. Please copy the actual log file from \(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/.logs/log.log").path) to view"
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
        return Log(value, forBundle: bundle, atTime: MapleLogController.formatter.string(from: Date.now), withType: type)
    }
    
    /// Adds a log from the app 
    /// - Parameter log: Log to display to the user
    public func local(log: String) {
        #if DEBUG
        print("+\(MapleLogController.formatter.string(from: Date.now)) [dev.halz.Maple] - \(log)")
        #endif
        self.addLog(self.makeLog(fromString: log, inBundle: "dev.halz.Maple"))
    }
}
