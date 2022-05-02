//
//  StatusBarController.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit

class StatusBarController {
    
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
    
    @objc func togglePopover(sender: AnyObject) {
        if self.popover.isShown {
            self.hidePopover(sender)
        } else {
            self.showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            self.popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            self.eventMonitor?.start()
        }
    }
    
    func hidePopover(_ sender: AnyObject) {
        self.popover.performClose(sender)
        self.eventMonitor?.stop()
    }
    
    func mouseEventHandler(_ event: NSEvent?) {
        if self.popover.isShown {
            self.hidePopover(event!)
        }
    }
}
