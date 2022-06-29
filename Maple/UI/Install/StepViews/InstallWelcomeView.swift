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
    
    private let steps: [String] = ["Select your .mapleleaf file", "Verify the information", "Finalize everything"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                Text("Ready to install your next Leaf?")
                    .font(.title2)
                    .bold()
                
                Text("This installer will guide you through the process. Below, you can see the steps!")
                    .padding(.bottom, 6)
                
                ForEach(self.steps, id: \.self) { step in
                    HStack {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                        Text(step)
                    }.padding(.bottom, 4)
                    .padding(.leading)
                }
            }
        }.onAppear {
            self.completed = true
            self.title = "Start installing a new Leaf"
        }
    }
}
