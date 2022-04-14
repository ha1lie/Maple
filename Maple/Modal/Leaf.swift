//
//  Leaf.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit

struct Leaf: Identifiable {
    
    var enabled: Bool = false
    var name: String? = nil
    var description: String? = nil
    var imageName: String? = nil
    var author: String? = nil
    var authorEmail: String? = nil
    var authorDiscord: String? = nil
    var tweakWebsite: String? = nil
    var libraryName: String? = nil
    var targetBundleID: String? = nil
    var leafID: String? = nil
    
    var id: ObjectIdentifier = .init(Leaf.self)
    
    /// Add a value to the initialized leaf
    /// - Parameter field: Line from Sap file
    public mutating func add(field: String) {
        let split: [String] = field.components(separatedBy: ": ")
        if split.count < 2 {
            print("Could not add field to Leaf, not enough information on line")
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
            self.targetBundleID = split[1]
        case "leaf-id":
            self.leafID = split[1]
        default:
            print("Ignoring line: " + field)
        }
    }
    
    /// Checks if a given Leaf is valid, eg. has enough information to run
    /// - Returns: true if valid
    public func isValid() -> Bool {
        return name != nil && description != nil && author != nil &&
            libraryName != nil && targetBundleID != nil && leafID != nil
    }
    
    /// Useless(non-functioning) Leaf object
    /// - Returns: Randomly generated Leaf object
    public static func generate() -> Leaf {
        let names: [String] = [
            "Carton",
            "Speaker Bump",
            "Slick mouse",
            "CoolCursor",
            "EasyKeys",
            "mE Apps"
        ]
        
        let descriptions: [String] = [
            "Integrate your authentication!",
            "Change your MacOS cursor",
            "Create some funky folders",
            "Smoooth a life",
            "MacOS. Redesigned. Flat",
            "Oranges. Oranges everywhere",
            "Super random description"
        ]
        
        return Leaf(enabled: false, name: names.randomElement() ?? "Slinky", description: descriptions.randomElement() ?? "Smooth your animations on MacOS", imageName: "folder.circle.fill")
    }
}
