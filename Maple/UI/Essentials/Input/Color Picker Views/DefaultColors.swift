//
//  ColorPickerFile.swift
//  Maple
//
//  Created by Hallie on 6/6/22.
//

import SwiftUI

struct DefaultColors: View {
    
    @Binding var selectedColor: Color
    
    var body: some View {
        VStack {
            HStack {
                ForEach([Color(.systemRed), Color(.systemOrange), Color(.systemYellow), Color(.systemGreen), Color(.systemTeal)], id: \.self) { color in
                    Button {
                        self.selectedColor = color
                    } label: {
                        ColorCell(color: color)
                    }.buttonStyle(PlainButtonStyle())
                    
                    if color != Color(.systemTeal) {
                        Spacer()
                    }
                }
            }.padding()
            
            HStack {
                ForEach([Color(.systemBlue), Color(.systemPurple), Color(.systemPink), Color.white, Color.black], id: \.self) { color in
                    Button {
                        self.selectedColor = color
                    } label: {
                        ColorCell(color: color)
                    }.buttonStyle(PlainButtonStyle())
                    
                    if color != Color.black {
                        Spacer()
                    }
                }
            }.padding([.horizontal, .bottom])
        }
    }
}
