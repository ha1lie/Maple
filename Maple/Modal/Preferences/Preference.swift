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
        print("SETTING COLOR TO UD")
        UserDefaults(suiteName: containerName)?.removeObject(forKey: id)
        UserDefaults(suiteName: containerName)?.setColor(val, forKey: id)
    }

    func getValue() -> Color? {
        print("GETTING COLOR FROM UD")
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
        print("Id: \(self.id) with value \(self.value)")
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
            print("SUCCESSFULLY GOT COLOR FROM USERDEFAULTS")
        }
    } else {
        if let newValue = UserDefaults(suiteName: pref.containerName)?.value(forKey: pref.id) as? T {
            val = newValue
            print("Successfully got an existing value for \(pref.id) is \(newValue)")
        }
    }
}

extension Color {

    /// Explicitly extracted Core Graphics color
    /// for the purpose of reconstruction and persistance.
    var cgColor_: CGColor {
        NSColor(self).cgColor
    }
}

extension UserDefaults {
    func setColor(_ color: Color, forKey key: String) {
        let cgColor = color.cgColor_
        let array = cgColor.components ?? []
        set(array, forKey: key)
    }

    func color(forKey key: String) -> Color {
        guard let array = object(forKey: key) as? [CGFloat] else { return .accentColor }
        let color = CGColor(colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, components: array)!
        return Color(color)
    }
}

//extension Color {
//
//    var components: [CGFloat] {
//        get {
//
//            if let comps = self.cgColor?.components {
//                return comps
//            } else {
//                print("COULDNT GET THE EASY COMPONENTS")
//            }
//
//            var red: CGFloat = 0.0
//            var green: CGFloat = 0.0
//            var blue: CGFloat = 0.0
//            var alpha: CGFloat = 0.0
//
//            NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//            return [red, green, blue, alpha]
//        }
//    }
//
//    public func toString() -> String {
//        return "\(self.components[0])|\(self.components[1])|\(self.components[2])|\(self.components[3])"
//    }
//
//    init(from val: String) {
//        let parts = val.components(separatedBy: "|")
//        if parts.count == 4 {
//            print("Making color from parts: \(parts)")
//            let red: Double = Double(parts[0]) ?? 1.0
//            let green: Double = Double(parts[1]) ?? 1.0
//            let blue: Double = Double(parts[2]) ?? 1.0
//            let alpha: Double = Double(parts[3]) ?? 1.0
//            self.init(red: red, green: green, blue: blue, opacity: alpha)
//        } else {
//            self.init(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
//        }
//    }
//}
