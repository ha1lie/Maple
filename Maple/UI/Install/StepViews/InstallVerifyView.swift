//
//  InstallVerifyView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallVerifyView: View {
    
    @Binding var completed: Bool
    @Binding var title: String
    @Binding var fileName: String
    @Binding var leaf: Leaf?
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            Button {
                self.completed = true
            } label: {
                Text("Complete")
            }
        }.onAppear {
            self.completed = false
            self.title = "Verify your Leaf package"
        }
    }
}
