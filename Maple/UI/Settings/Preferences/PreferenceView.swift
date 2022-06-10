//
//  PreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct PreferenceView: View {
    let preference: any Preference
    
    var body: some View {
        VStack {
            if let pref = self.preference as? BoolPreference {
                BooleanPreferenceView(preference: pref)
            } else if let pref = self.preference as? StringPreference {
                StringPreferenceView(preference: pref)
            } else if let pref = self.preference as? ColorPreference {
                ColorPreferenceView(preference: pref)
            } else if let pref = self.preference as? NumberPreference {
                NumberPreferenceView(preference: pref)
            } else {
                UnknownPreferenceView(preference: self.preference)
            }
        }
    }
}
