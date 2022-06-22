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
    @State var ignore: Bool = true
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
            switch self.preference.getValue() {
            case .bool(let value):
                if let value = value {
                    self.enabled = value
                }
            default:
                self.ignore = false
                return
            }
            self.ignore = false
        }.onChange(of: self.enabled) { newValue in
            if !self.ignore {
                self.preference.setValue(.bool(newValue))
            }
        }
    }
}
