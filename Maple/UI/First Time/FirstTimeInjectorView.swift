//
//  FirstTimeInjectorView.swift
//  Maple
//
//  Created by Hallie on 7/3/22.
//

import SwiftUI

struct FirstTimeInjectorView: View {
    @Binding var subtitle: String
    @Binding var canContinue: Bool
    
    @State var hadError: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if !self.hadError {
                Text("Maple uses a utility called a *Library Injector* to be able to add your Leaves custom code to existing apps or daemons on your device. It's responsible for using EndpointSecurity to listen for new processes, and then adds your code to override the binary's original implementation")
                
                Button {
                    if let github = URL(string: "https://github.com/ha1lie/Maple-LibInjector") {
                        NSWorkspace.shared.open(github)
                    }
                } label: {
                    HStack {
                        Text("Read more on GitHub")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                    }.foregroundColor(.accentColor)
                }.buttonStyle(PlainButtonStyle())
                
                HStack {
                    Spacer()
                    MapleButton(action: {
                        MapleController.shared.installInjector { success in
                            if !success {
                                self.hadError = true
                            }
                        }
                        if !self.hadError {
                            self.canContinue = true
                        }
                    }, title: "Install Maple's Injector")
                    Spacer()
                }
            } else {
                Group {
                    Text("Oops!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.red)
                    
                    Text("There's been an error")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.red)
                    
                    Text("Please quit Maple, and re-open it to try again")
                }
            }
        }.onAppear {
            self.subtitle = "Install Maple's Library Injector"
            self.canContinue = false
        }
    }
}
