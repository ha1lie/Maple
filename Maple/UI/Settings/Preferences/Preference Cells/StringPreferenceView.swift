//
//  StringPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct StringPreferenceView: View {
    let preference: Preference
    var body: some View {
        VStack(alignment: .leading) {
            if self.preference.valueType == .string {
                HStack {
                    Text(self.preference.name)
                        .bold()
                    MapleTextField(title: self.preference.name, value: .constant(""))
                }
                if let description = self.preference.description {
                    Text(description)
                }
            } else {
                Text("Error Parsing Preference")
                    .foregroundColor(.red)
                    .bold()
            }
        }
    }
}
