//
//  MapleButton.swift
//  Maple
//
//  Created by Hallie on 4/4/22.
//

import SwiftUI

/// Button which conforms to Maple's design style
struct MapleButton: View {
    /// Action performed when clicked
    let action: () -> Void
    /// Title to display on the button
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
