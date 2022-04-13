//
//  InstallStartView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallStartView: View {
    
    @Binding var complete: Bool
    @Binding var title: String
    @Binding var leaf: Leaf?
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            Button {
                self.complete = false
            } label: {
                Text("Complete")
            }
        }.onAppear {
            self.complete = false
            self.title = "Confirm your Leaf package"
        }
    }
}
