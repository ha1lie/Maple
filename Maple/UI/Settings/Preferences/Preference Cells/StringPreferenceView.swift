//
//  StringPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct StringPreferenceView: View {
    let preference: Preference
    
    @State var ignore: Bool = true
    
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
            switch self.preference.getValue() {
            case .string(let stringValue):
                if let stringValue = stringValue {
                    self.value = stringValue
                }
            default:
                self.ignore = false
                return
            }
            self.ignore = false
        }.onChange(of: self.value) { newValue in
            if !self.ignore {
                self.preference.setValue(newValue)
            }
        }
    }
}
