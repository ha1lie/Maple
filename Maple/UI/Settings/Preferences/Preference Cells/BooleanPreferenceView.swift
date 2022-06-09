//
//  BooleanPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct BooleanPreferenceView: View {
    let preference: Preference
    var body: some View {
        VStack(alignment: .leading) {
            if self.preference.valueType == .boolean {
                HStack {
                    Toggle(isOn: .constant(true), label: {})
                        .toggleStyle(SwitchToggleStyle())
                        .rotationEffect(Angle(degrees: 270))
                    VStack(alignment: .leading) {
                        Text(self.preference.name)
                            .font(.system(size: 14, weight: .medium))
                        if let description = self.preference.description {
                            Text(description)
                        }
                    }
                }
            } else {
                Text("Error Parsing Preference")
                    .foregroundColor(.red)
                    .bold()
            }
        }
    }
}
