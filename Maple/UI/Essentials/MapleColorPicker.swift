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
    
    var body: some View {
        Button {
            self.showPicker.toggle()
        } label: {
            ColorCell(color: self.selectedColor)
        }.buttonStyle(PlainButtonStyle())
        .popover(isPresented: self.$showPicker) {
            VStack {
                DefaultColors(selectedColor: self.$selectedColor)
            }.frame(width: 300)
        }
    }
}
