//
//  StringPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct StringPreferenceView: View {
    let preference: StringPreference
    
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
            MapleTextField(title: self.preference.name, value: .constant(""))
                .frame(maxWidth: 200)
        }.padding(.bottom)
    }
}
