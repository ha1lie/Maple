//
//  EventMonitor.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit

/// Monitor watching for events on the status bar application
class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        self.stop()
    }
    
    public func start() {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler:self.handler) as! NSObject
    }
    
    func stop() {
        if self.monitor != nil {
            NSEvent.removeMonitor(self.monitor!)
            self.monitor = nil
        }
    }
}
