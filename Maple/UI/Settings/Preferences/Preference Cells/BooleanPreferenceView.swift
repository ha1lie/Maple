//
//  BooleanPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct BooleanPreferenceView: View {
    let preference: Preference
    @State var enabled: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.preference.name)
                    .font(.system(size: 14, weight: .bold))
                if let description = self.preference.description {
                    Text(description)
                }
            }
            
            Spacer()
            
            Toggle(isOn: self.$enabled, label: {})
                .toggleStyle(SwitchToggleStyle())
        }.padding(.bottom)
        .onAppear {
            if let result: PreferenceValue = self.preference.getValue() {
                switch result {
                case .bool(let value):
                    if let value = value {
                        self.enabled = value
                    }
                default:
                    return
                }
            }
        }.onChange(of: self.enabled) { newValue in
            self.preference.setValue(newValue)
        }
    }
}
