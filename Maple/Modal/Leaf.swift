//
//  Leaf.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit

class Leaf: Identifiable, Codable, Equatable, Hashable {
    
    var enabled: Bool = false
    var name: String? = nil
    var description: String? = nil
    var imageName: String? = nil
    var author: String? = nil
    var authorEmail: String? = nil
    var authorDiscord: String? = nil
    var tweakWebsite: String? = nil
    var libraryName: String? = nil
    var targetBundleID: [String]? = nil
    var leafID: String? = nil
    
    /// Add a value to the initialized leaf
    /// - Parameter field: Line from Sap file
    public func add(field: String) throws {
        let split: [String] = field.components(separatedBy: ": ")
        if split.count < 2 {
            return
        }
        switch split[0] {
        case "name":
            self.name = split[1]
        case "author":
            self.author = split[1]
        case "author-email":
            self.authorEmail = split[1]
        case "author-discord":
            self.authorDiscord = split[1]
        case "tweak-website":
            self.tweakWebsite = split[1]
        case "description":
            self.description = split[1]
        case "image":
            self.imageName = split[1]
        case "lib-name":
            self.libraryName = split[1]
        case "target-bundle-id":
            let inputs = split[1].components(separatedBy: " ")
            self.targetBundleID = inputs
        case "leaf-id":
            self.leafID = split[1]
        default:
            return
        }
    }
    
    /// Toggles the enability of this Leaf
    public func toggleEnable() {
        if self.enabled {
            self.enabled = false
        } else {
            self.enabled = true
        }
        MapleController.shared.updateLocallyStoredLeaves()
    }
    
    /// Checks if a given Leaf is valid, eg. has enough information to run
    /// - Returns: true if valid
    public func isValid() -> Bool {
        return name != nil && description != nil && author != nil &&
            libraryName != nil && targetBundleID != nil && leafID != nil &&
            name != "" && description != "" && author != "" &&
            targetBundleID != [] && leafID != ""  
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.leafID)
    }
    
    static func == (lhs: Leaf, rhs: Leaf) -> Bool {
        return lhs.leafID == rhs.leafID
    }
    
    enum CodingKeys: String, CodingKey {
        case enabled = "enabled"
        case name = "name"
        case description = "description"
        case imageName = "image_name"
        case author = "author"
        case authorEmail = "author-email"
        case authorDiscord = "author-discord"
        case tweakWebsite = "tweak-website"
        case libraryName = "library-name"
        case targetBundleID = "target-bid"
        case leafID = "leaf-id"
    }
}
