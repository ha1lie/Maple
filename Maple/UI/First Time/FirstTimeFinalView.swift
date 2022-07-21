//
//  FirstTimeFinalView.swift
//  Maple
//
//  Created by Hallie on 7/3/22.
//

import SwiftUI

struct FirstTimeFinalView: View {
    @Binding var subtitle: String
    
    let finalize: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text("Congrats!")
                    .font(.title2)
                    .bold()
                
                Text("It's time to get started using your Mac to it's full potential")
                
                Button {
                    if let website = URL(string: "https://maple.halz.dev") {
                        NSWorkspace.shared.open(website)
                    }
                } label: {
                    HStack {
                        Text("Read more online")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                    }.foregroundColor(.accentColor)
                }.buttonStyle(PlainButtonStyle())
                
                MapleButton(action: {
                    self.finalize()
                    MapleController.shared.openWindowToInstallLeaf()
                }, title: "Install Your First Leaf")

            }
            Spacer()
        }.onAppear {
            self.subtitle = "Finalize"
        }
    }
}
