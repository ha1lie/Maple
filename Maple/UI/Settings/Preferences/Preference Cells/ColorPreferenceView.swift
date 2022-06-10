//
//  ColorPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct ColorPreferenceView: View {
    let preference: ColorPreference
    
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
    }
}
