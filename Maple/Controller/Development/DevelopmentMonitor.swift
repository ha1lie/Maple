//
//  DevelopmentMonitor.swift
//  Maple
//
//  Created by Hallie on 5/24/22.
//

import Foundation

class DevelopmentMonitor {
    private let devFolderMonitorQueue: DispatchQueue = DispatchQueue(label: "DevFolderMonitorQueue", attributes: [.concurrent])
    
    private var devFolderMonitorSource: DispatchSourceFileSystemObject?
    private var devFolderFileDescriptor: CInt = -1
    
    private var currentContents: [String] = []
    
    /// Begin monitoring for events in the dev folder
    public func startMonitoring() {
        guard self.devFolderMonitorSource == nil && self.devFolderFileDescriptor == -1 else { return }
        self.devFolderFileDescriptor = open(MapleDevelopmentHelper.devFolderURL.path, O_EVTONLY)
        
        self.devFolderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.devFolderFileDescriptor, eventMask: .write, queue: self.devFolderMonitorQueue)
        
        self.devFolderMonitorSource?.setEventHandler(handler: {
            self.devFolderDidChange()
        })
        
        self.devFolderMonitorSource?.setCancelHandler(handler: {
            print("DevelopmentMonitor cancelling it's handler")
            close(self.devFolderFileDescriptor)
            self.devFolderFileDescriptor = -1
            self.devFolderMonitorSource = nil
        })
        
        self.devFolderMonitorSource?.resume()
        
        self.currentContents = self.getContentsOfDevFolder()
    }
    
    public func stop() {
        self.devFolderMonitorSource?.cancel()
        self.devFolderMonitorSource = nil
    }
    
    public func getContentsOfDevFolder() -> [String] {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: MapleDevelopmentHelper.devFolderString)
        } catch {
            print("Failed to get contents")
        }
        return []
    }
    
    /// An event called when there is a change to the contents of the development folder
    public func devFolderDidChange() {
        let newContents = self.getContentsOfDevFolder()
        for file in newContents {
            if self.currentContents.firstIndex(of: file) == nil {
                // Check if we can make a valid file object, and get the file ending from it!
                print("File path: \(MapleDevelopmentHelper.devFolderString + "/" + file)")
                let fileAddition = MapleDevelopmentHelper.devFolderURL.appendingPathComponent(file)
                if fileAddition.isFileURL && fileAddition.pathExtension == "zip" { //TODO: Make this actually a mapleleaf file
                    do {
                        try MapleDevelopmentHelper.shared.installDevLeaf(fileAddition)
                    } catch {
                        print("The file put there was not a leaf... deleting")
                        try? FileManager.default.removeItem(at: fileAddition)
                        return
                    }
                } else {
                    print("File is either a directory or not a leaf")
                    try? FileManager.default.removeItem(at: fileAddition)
                }
            }
        }
        self.currentContents = newContents
    }
    
}
