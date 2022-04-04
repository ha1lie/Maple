//
//  InstallSelectView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallSelectView: View {
    
    @State var completed: Bool = false
    
    var title: String = "Select your Leaf package"
    
    var body: some View {
        VStack {
            Text("Select the proper leaf package")
            
            Button {
                self.completed = true
            } label: {
                Text("Complete")
            }

        }
    }
}
