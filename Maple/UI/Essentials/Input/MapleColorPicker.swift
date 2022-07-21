//
//  MapleColorPicker.swift
//  Maple
//
//  Created by Hallie on 6/6/22.
//

import SwiftUI

struct MapleColorPicker: View {
    
    @Binding var selectedColor: Color
    
    @State var showPicker: Bool = false
    
    @State var selectedView: Int = 0
    
    var body: some View {
        Button {
            self.showPicker.toggle()
        } label: {
            ColorCell(color: self.selectedColor)
        }.buttonStyle(PlainButtonStyle())
        .popover(isPresented: self.$showPicker) {
            VStack {
                MapleSegmentPicker(withOptions: ["Defaults", "Custom"], andValue: self.$selectedView)
                if self.selectedView == 0 {
                    DefaultColors(selectedColor: self.$selectedColor)
                } else {
                    CustomColorView(selectedColor: self.$selectedColor)
                }
            }.frame(width: 300)
                .padding()
        }
    }
}
