//
//  StatusBarController.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit

/// Controls status bar app events
class StatusBarController {
    
    /// Singleton StatusBarController
    static var shared: StatusBarController?
    
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var eventMonitor: EventMonitor?
    
    init(_ popover: NSPopover) {
        self.popover = popover
        self.statusBar = NSStatusBar()
        self.statusItem = statusBar.statusItem(withLength: 30)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "leaf.fill", accessibilityDescription: "Maple")
            statusBarButton.image?.size = NSSize(width: 18, height: 18)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
        
        self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler(_:))
        
        StatusBarController.shared = self
    }
    
    /// Hide if shown, show if hidden
    /// - Parameter sender: Object which calls for this action
    @objc func togglePopover(sender: AnyObject) {
        if self.popover.isShown {
            self.hidePopover(sender)
        } else {
            self.showPopover(sender)
        }
    }
    
    /// Display the status bar application
    /// - Parameter sender: Object calling for this action
    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            self.popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            self.eventMonitor?.start()
        }
    }
    
    /// Hide the status bar application
    /// - Parameter sender: Object calling for this action
    func hidePopover(_ sender: AnyObject) {
        self.popover.performClose(sender)
        self.eventMonitor?.stop()
    }
    
    /// Handler for click actions
    /// - Parameter event: Event object requiring action
    func mouseEventHandler(_ event: NSEvent?) {
        if self.popover.isShown {
            self.hidePopover(event!)
        }
    }
}
