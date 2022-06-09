//
//  Preference.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import Foundation

struct Preferences: Codable {
    let generalPreferences: [Preference]?
    let preferenceGroups: [PreferenceGroup]?
}

struct PreferenceGroup: Codable, Identifiable, Hashable {
    let preferences: [Preference]
    let name: String
    let description: String
    let id = UUID()
}

struct Preference: Codable, Identifiable, Hashable {
    let preferenceKey: String
    let name: String
    let description: String?
    let valueType: PreferenceType
    let value: String //TODO: Make this work
    let id = UUID()
}

enum PreferenceType: Codable, Equatable {
    case string
    case number
    case boolean
    case color
}
