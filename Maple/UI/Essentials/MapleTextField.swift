//
//  MapleTextField.swift
//  Maple
//
//  Created by Hallie on 6/6/22.
//

import SwiftUI

struct MapleTextField: View {
    
    let title: String
    @Binding var value: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(.gray.opacity(0.3))
                .frame(height: 26)
            TextField(self.title, text: self.$value)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(6)
        }
    }
}
