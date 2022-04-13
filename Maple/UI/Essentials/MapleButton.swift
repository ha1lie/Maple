//
//  MapleButton.swift
//  Maple
//
//  Created by Hallie on 4/4/22.
//

import SwiftUI

struct MapleButton: View {
    let action: () -> Void
    let title: String
    
    var body: some View {
        Button {
            self.action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.blue)
                Text(self.title.uppercased())
                    .padding(.horizontal)
            }.frame(height: 40).fixedSize()
        }.buttonStyle(PlainButtonStyle())
    }
}
