//
//  StringPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct StringPreferenceView: View {
    let preference: StringPreference
    @State var value: String = ""
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
            MapleTextField(title: self.preference.name, value: self.$value)
                .frame(maxWidth: 200)
        }.padding(.bottom)
        .onAppear {
            self.value = self.preference.value
        }.onChange(of: self.value) { newValue in
            self.preference.setValue(newValue)
        }
    }
}
