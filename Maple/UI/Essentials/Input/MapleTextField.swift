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
    
    let onSubmit: (() -> Void)?
    
    init(title: String, value: Binding<String>, onSubmit: (() -> Void)? = nil) {
        self.title = title
        self._value = value
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(.gray.opacity(0.3))
                .frame(height: 26)
            TextField(self.title, text: self.$value, onCommit: {
                if let onSubmit = self.onSubmit {
                    onSubmit()
                }
            })
                .textFieldStyle(PlainTextFieldStyle())
                .padding(6)
        }
    }
}
