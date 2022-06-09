//
//  ColorPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct ColorPreferenceView: View {
    let preference: Preference
    
    @State var selectedColor: Color = .blue
    
    var body: some View {
        VStack {
            if self.preference.valueType == .color {
                HStack {
                    MapleColorPicker(selectedColor: self.$selectedColor)
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
