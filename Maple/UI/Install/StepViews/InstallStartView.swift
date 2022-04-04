//
//  InstallStartView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallStartView: View {
    
    @State var completed: Bool = false
    
    var title: String = "Confirm your Leaf package"
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        Button {
            self.completed = true
        } label: {
            Text("Complete")
        }
    }
}

struct InstallStartView_Previews: PreviewProvider {
    static var previews: some View {
        InstallStartView()
    }
}
