//
//  FirstTimeOrientationView.swift
//  Maple
//
//  Created by Hallie on 7/3/22.
//

import SwiftUI

struct FirstTimeOrientationView: View {
    @Binding var subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nice! You've downloaded Maple. Now, it's time to configure a few things!")
            Text("We'll need your administrator password for a few things, but don't worry, we can explain beforehand!")
            
            Text("Just a few more steps, and you'll be on your way making your Mac **yours!**")
        }.onAppear {
            self.subtitle = "Get yourself orientated"
        }
    }
}
