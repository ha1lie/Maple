//
//  Leaf.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import AppKit

struct Leaf {
    var enabled: Bool = false
    var name: String = ""
    var shortDescription: String = ""
    var imageName: String = ""
    
    public func getImage() -> NSImage? {
        return nil
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
        
        return Leaf(enabled: false, name: names.randomElement() ?? "Slinky", shortDescription: descriptions.randomElement() ?? "Smooth your animations on MacOS", imageName: "folder.circle.fill")
    }
}
