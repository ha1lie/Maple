//
//  ColorPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct ColorPreferenceView: View {
    let preference: Preference
    
    @State var selectedColor: Color = .blue
    
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
            
            MapleColorPicker(selectedColor: self.$selectedColor)
        }.padding(.bottom)
        .onAppear {
            if let result = self.preference.getValue() {
                switch result {
                case .color(let colorValue):
                    if let colorValue = colorValue {
                        self.selectedColor = colorValue
                    }
                default:
                    return
                }
            }
        }.onChange(of: self.selectedColor) { newValue in
            self.preference.setValue(newValue)
        }
    }
}
