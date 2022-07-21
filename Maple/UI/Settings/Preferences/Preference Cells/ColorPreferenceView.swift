//
//  ColorPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MapleKit

struct ColorPreferenceView: View {
    let preference: Preference
    @State var ignore: Bool = true
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
            switch self.preference.getValue() {
            case .color(let colorValue):
                if let colorValue = colorValue {
                    self.selectedColor = colorValue
                }
            default:
                self.ignore = false
                return
            }
            self.ignore = false
        }.onChange(of: self.selectedColor) { newValue in
            if !self.ignore {
                self.preference.setValue(.color(newValue))
            }
        }
    }
}
