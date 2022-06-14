//
//  Preference.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import Foundation
import SwiftUI

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
    
    func setValue(_ val: Color) {
        UserDefaults(suiteName: containerName)?.removeObject(forKey: id)
        UserDefaults(suiteName: containerName)?.setColor(val, forKey: id)
    }

    func getValue() -> Color? {
        return UserDefaults(suiteName: containerName)?.color(forKey: id)
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
    }
}

protocol Preference: Identifiable, Hashable {
    associatedtype PreferenceValueType: Equatable
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
        UserDefaults(suiteName: containerName)?.removeObject(forKey: id)
        UserDefaults(suiteName: containerName)?.set(val, forKey: id)
    }
    
    func getValue() -> PreferenceValueType? {
        return UserDefaults(suiteName: containerName)?.value(forKey: id) as? PreferenceValueType
    }
}

func ValueOfPreference<T>(_ pref: any Preference, assignTo val: inout T) {
    if T.self == Color.self {
        if let newValue = UserDefaults(suiteName: pref.containerName)?.color(forKey: pref.id) {
            val = newValue as! T
        }
    } else {
        if let newValue = UserDefaults(suiteName: pref.containerName)?.value(forKey: pref.id) as? T {
            val = newValue
        }
    }
}

extension Color {
    /// CGColor created coercively without SwiftUI slipping up
    var cgColor_: CGColor {
        NSColor(self).cgColor
    }
}

extension UserDefaults {
    /// Save value of a Color to UserDefaults
    /// - Parameters:
    ///   - color: Color to save
    ///   - key: Key to save Color value to
    func setColor(_ color: Color, forKey key: String) {
        let cgColor = color.cgColor_
        let array = cgColor.components ?? []
        set(array, forKey: key)
    }
    
    /// Get Color value in UserDefaults
    /// - Parameter key: Key color value is stored at
    /// - Returns: Color, if previously stored
    func color(forKey key: String) -> Color? {
        guard let array = object(forKey: key) as? [CGFloat] else { return nil }
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: array)!
        return Color(color)
    }
}
