//
//  PreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct PreferenceView: View {
    let preference: Preference
    
    var body: some View {
        VStack {
            switch self.preference.valueType {
            case .string:
                StringPreferenceView(preference: self.preference)
            case .boolean:
                BooleanPreferenceView(preference: self.preference)
            case .color:
                ColorPreferenceView(preference: self.preference)
            case .number:
                NumberPreferenceView()
            }
        }
    }
}
