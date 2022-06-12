//
//  PreferenceGroup.swift
//  Maple
//
//  Created by Hallie on 6/10/22.
//

import Foundation

class PreferenceGroup: Identifiable, Hashable {
    var containerName: String
    var preferences: [any Preference]?
    var name: String
    var description: String?
    var id: String
    
    init(withName name: String, description: String? = nil, andIdentifier id: String, forContainer container: String) {
        self.name = name
        self.description = description
        self.id = id
        self.containerName = container
    }
    
    func withPreference(_ creator: (_ groupContainer: String) -> any Preference) -> PreferenceGroup {
        if self.preferences == nil {
            self.preferences = []
        }
        self.preferences?.append(creator(self.containerName))
        return self
    }
    
    static func == (lhs: PreferenceGroup, rhs: PreferenceGroup) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
    }
}
