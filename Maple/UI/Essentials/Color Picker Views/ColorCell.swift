//
//  ColorCell.swift
//  Maple
//
//  Created by Hallie on 6/6/22.
//

import SwiftUI

struct ColorCell: View {
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            Circle()
                .foregroundColor(self.color)
                .frame(width: 26, height: 26)
        }
    }
}
