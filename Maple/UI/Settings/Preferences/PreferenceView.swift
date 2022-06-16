//
//  PreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct PreferenceView: View {
    let preference: Preference
    
    var body: some View {
        VStack {
            switch self.preference.preferenceType {
            case .string:
                StringPreferenceView(preference: self.preference)
            case .bool:
                BooleanPreferenceView(preference: self.preference)
            case .number:
                NumberPreferenceView(preference: self.preference)
            case .color:
                ColorPreferenceView(preference: self.preference)
            case .unknown:
                UnknownPreferenceView(preference: self.preference)
            }
        }
    }
}
