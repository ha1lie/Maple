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
                ForEach([Color(nsColor: .systemRed), Color(nsColor: .systemOrange), Color(nsColor: .systemYellow), Color(nsColor: .systemGreen), Color(nsColor: .systemTeal)], id: \.self) { color in
                    Button {
                        self.selectedColor = color
                    } label: {
                        ColorCell(color: color)
                    }.buttonStyle(PlainButtonStyle())
                    
                    if color != Color(nsColor: .systemTeal) {
                        Spacer()
                    }
                }
            }.padding()
            
            HStack {
                ForEach([Color(nsColor: .systemBlue), Color(nsColor: .systemPurple), Color(nsColor: .systemPink), Color.white, Color.black], id: \.self) { color in
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
