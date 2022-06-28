//
//  Leaf.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit
import MaplePreferences

class Leaf: ObservableObject, Identifiable, Codable, Equatable, Hashable, CustomStringConvertible {
    var description: String {
        return "Leaf(enabled: \(self.enabled), name:\(self.name ?? ""), description: \(self.leafDescription ?? ""), author: \(self.author ?? ""), libraryName: \(self.libraryName ?? ""), targetBundleID: \(self.targetBundleID ?? [""]), leafID: \(self.leafID ?? ""), development: \(self.development))"
    }
    
    
    @Published var enabled: Bool = false
    @Published var name: String? = nil
    @Published var leafDescription: String? = nil
    @Published var imageName: String? = nil
    @Published var author: String? = nil
    @Published var authorEmail: String? = nil
    @Published var authorDiscord: String? = nil
    @Published var tweakWebsite: String? = nil
    @Published var libraryName: String? = nil
    @Published var targetBundleID: [String]? = nil
    @Published var leafID: String? = nil
    @Published var development: Bool = false
    var hasPreferences: Bool = false
    
    var preferences: Preferences? {
        get {
            if self.hasPreferences && self.leafID != nil {
                return Leaf.getPreferences(forLeaf: self)
            } else {
                return nil
            }
        }
    }
    
    static private func getPreferences(forLeaf leaf: Leaf) -> Preferences? {
        return Preferences.fromLeaf(leaf)
    }
    
    init() { }
    
    /// Add a value to the initialized leaf
    /// - Parameter field: Line from Sap file
    public func add(field: String) {
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
            self.leafDescription = split[1]
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
        MapleController.shared.reloadInjection()
    }
    
    /// Checks if a given Leaf is valid, eg. has enough information to run
    /// - Returns: true if valid
    public func isValid() -> Bool {
        return name != nil && leafDescription != nil && author != nil &&
            libraryName != nil && targetBundleID != nil && leafID != nil &&
            name != "" && leafDescription != "" && author != "" &&
            targetBundleID != [] && leafID != ""  
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.leafID)
    }
    
    static func == (lhs: Leaf, rhs: Leaf) -> Bool {
        return lhs.leafID == rhs.leafID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(name, forKey: .name)
        try container.encode(leafDescription, forKey: .description)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(author, forKey: .author)
        try container.encode(authorEmail, forKey: .authorEmail)
        try container.encode(authorDiscord, forKey: .authorDiscord)
        try container.encode(tweakWebsite, forKey: .tweakWebsite)
        try container.encode(libraryName, forKey: .libraryName)
        try container.encode(targetBundleID, forKey: .targetBundleID)
        try container.encode(leafID, forKey: .leafID)
        try container.encode(development, forKey: .development)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enabled = try container.decode(Bool.self, forKey: .enabled)
        self.name = try container.decode(String?.self, forKey: .name)
        self.leafDescription = try container.decode(String?.self, forKey: .description)
        self.imageName = try container.decode(String?.self, forKey: .imageName)
        self.author = try container.decode(String?.self, forKey: .author)
        self.authorEmail = try container.decode(String?.self, forKey: .authorEmail)
        self.authorDiscord = try container.decode(String?.self, forKey: .authorDiscord)
        self.tweakWebsite = try container.decode(String?.self, forKey: .tweakWebsite)
        self.libraryName = try container.decode(String?.self, forKey: .libraryName)
        self.targetBundleID = try container.decode([String]?.self, forKey: .targetBundleID)
        self.leafID = try container.decode(String?.self, forKey: .leafID)
        self.development = try container.decode(Bool.self, forKey: .development)
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
        case development = "development"
    }
}
