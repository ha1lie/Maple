//
//  MapleNotificationController.swift
//  Maple
//
//  Created by Hallie on 4/15/22.
//

import Foundation
import AppKit
import UserNotifications

class MapleNotificationController {
    static let shared: MapleNotificationController = MapleNotificationController()
    
    /// Sends a notification to the user
    /// - Parameters:
    ///   - t: Title of the notification
    ///   - body: The body of the notification
    public func sendLocalNotification(withTitle t: String, body: String) {
        let nContent = UNMutableNotificationContent()
        nContent.title = t
        nContent.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: nContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { er in
            print("Error adding request: \(er.debugDescription)")
        }
    }
    
    /// Sends an alert to the user, which can gather input
    /// - Parameters:
    ///   - t: Title of the alert
    ///   - b: Body of the alert
    ///   - options: Options presented to the user
    ///          *MUST BE OF LENGTH 2*
    /// - Returns: Option chosen by the user in plaintext
    public func sendUserDialogue(withTitle t: String, andBody b: String, withOptions options: [String]? = []) -> String {
        let alert = NSAlert()
        alert.messageText = t
        alert.informativeText = b
        if options != nil && options!.count == 2 {
            for option in options! {
                alert.addButton(withTitle: option)
            }
            return alert.runModal() == .alertFirstButtonReturn ? options![0] : options![1]
        } else {
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            return alert.runModal() == .alertFirstButtonReturn ? "OK" : "Cancel"
        }
    }
}
