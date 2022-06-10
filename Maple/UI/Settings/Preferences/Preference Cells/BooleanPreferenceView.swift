//
//  BooleanPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct BooleanPreferenceView: View {
    let preference: BoolPreference
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
            self.enabled = self.preference.value
        }.onChange(of: self.enabled) { newValue in
            self.preference.setValue(newValue)
        }
    }
}
