//
//  Preference.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import Foundation
import SwiftUI

class Preferences {
    var generalPreferences: [any Preference]?
    var preferenceGroups: [PreferenceGroup]?
    
    let bundleIdentifier: String
    
    static var mapleAppPreferences: Preferences {
        return Preferences(forBundle: "dev.halz.Maple.app")
            .withGroup { containerName in
                PreferenceGroup(withName: "General", description: "General pickings and choosings", andIdentifier: "dev.halz.Maple.prefs.general", forContainer: containerName)
                    .withPreference { groupContainer in
                        BoolPreference(withTitle: "Enable At Login", description: "Allow Maple to launch at login and enable your leaves without doing anything", defaultValue: false, andIdentifier: "dev.halz.Maple.prefs.general.loginEnabled", forContainer: groupContainer)
                    }.withPreference { groupContainer in
                        BoolPreference(withTitle: "Enable Injection", defaultValue: true, andIdentifier: "dev.halz.Maple.prefs.general.enabledInjection", forContainer: groupContainer)
                    }.withPreference { groupContainer in
                        ColorPreference(withTitle: "Themed Color", defaultValue: .green, andIdentifier: "dev.halz.Maple.prefs.general.themeColor", forContainer: groupContainer)
                    }
            }.withGroup { containerName in
                PreferenceGroup(withName: "Development", andIdentifier: "dev.halz.Maple.prefs.development", forContainer: containerName)
                    .withPreference { groupContainer in
                        BoolPreference(withTitle: "Development Mode", description: "When enabled, developoment mode is active, allowing for detailed logs, faster rebuilds, and a better more secure development experience", defaultValue: false, andIdentifier: "dev.halz.Maple.prefs.general.enableDevelopment", forContainer: groupContainer)
                    }
            }
    }
    
    init(forBundle bid: String) {
        self.generalPreferences = nil
        self.preferenceGroups = nil
        self.bundleIdentifier = bid
    }
    
    static func fromBID(_ bid: String) -> Preferences? {
        return nil
    }
    
    func withGroup(_ creator: (_ containerName: String) -> PreferenceGroup) -> Preferences {
        if self.preferenceGroups == nil {
            self.preferenceGroups = []
        }
        
        self.preferenceGroups?.append(creator(self.bundleIdentifier))
        return self
    }
    
    func withPreference(_ creator: (_ containerName: String) -> any Preference) -> Preferences {
        if self.generalPreferences == nil {
            self.generalPreferences = []
        }
        self.generalPreferences?.append(creator(self.bundleIdentifier))
        return self
    }
}

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

struct ColorPreference: Preference {
    var containerName: String
    var name: String
    var description: String?
    var value: Color
    var id: String
    typealias PreferenceValueType = Color
    
    init(withTitle name: String, description: String? = nil, defaultValue value: Color, andIdentifier id: String, forContainer container: String) {
        self.name = name
        self.description = description
        self.containerName = container
        self.id = id
        self.value = value
        ValueOfPreference(self, assignTo: &self.value)
    }
}

struct NumberPreference: Preference {
    var containerName: String
    var name: String
    var description: String?
    var value: CGFloat
    var id: String
    typealias PreferenceValueType = CGFloat
    
    init(withTitle name: String, description: String? = nil, defaultValue value: CGFloat, andIdentifier id: String, forContainer container: String) {
        self.name = name
        self.description = description
        self.containerName = container
        self.id = id
        self.value = value
        ValueOfPreference(self, assignTo: &self.value)
    }
}

struct StringPreference: Preference {
    var containerName: String
    var name: String
    var description: String?
    var value: String
    var id: String
    typealias PreferenceValueType = String
    
    init(withTitle name: String, description: String? = nil, defaultValue value: String, andIdentifier id: String, forContainer container: String) {
        self.name = name
        self.description = description
        self.containerName = container
        self.id = id
        self.value = value
        ValueOfPreference(self, assignTo: &self.value)
    }
}

struct BoolPreference: Preference {
    var containerName: String
    var name: String
    var description: String?
    var value: Bool
    var id: String
    typealias PreferenceValueType = Bool
    
    init(withTitle name: String, description: String? = nil, defaultValue value: Bool, andIdentifier id: String, forContainer container: String) {
        self.name = name
        self.description = description
        self.id = id
        self.containerName = container
        self.value = value
        ValueOfPreference(self, assignTo: &self.value)
        print("Id: \(self.id) with value \(self.value)")
    }
}

protocol Preference: Identifiable, Hashable {
    associatedtype PreferenceValueType
    var name: String { get set }
    var description: String? { get set }
    var value: PreferenceValueType { get set }
    var id: String { get set }
    var containerName: String { get set }
    
    func setValue(_ val: PreferenceValueType)
}

extension Preference {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(description)
    }
    
    static func == (lhs: any Preference, rhs: any Preference) -> Bool {
        return lhs.id == rhs.id
    }
    
    func setValue(_ val: PreferenceValueType) {
        print("Setting value for \(self.id) to \(val)")
        UserDefaults(suiteName: containerName)?.set(value, forKey: id)
    }
    
    func getValue() -> PreferenceValueType? {
        print("Getting value for \(self.id)")
        return UserDefaults(suiteName: containerName)?.value(forKey: id) as? PreferenceValueType
    }
}

func ValueOfPreference<T>(_ pref: any Preference, assignTo val: inout T) {
    if let newValue = UserDefaults(suiteName: pref.containerName)?.value(forKey: pref.id) as? T {
        val = newValue
        print("Successfully got an existing value for \(pref.id) is \(newValue)")
    }
}
