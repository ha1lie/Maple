//
//  InstallWelcomeView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallWelcomeView: View {
    
    @Binding var completed: Bool
    @Binding var title: String
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                Text("It looks like you'd like to install a new Leaf🍃 for Maple🍁. This will help you install the Leaf, verify that you trust the source and what it does, and get it up and running! It's super simple, so let's get started!")
            }
        }.onAppear {
            self.completed = true
            self.title = "Start installing a new Leaf"
        }
    }
}
