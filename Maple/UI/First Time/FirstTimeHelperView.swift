//
//  FirstTimeHelperWindow.swift
//  Maple
//
//  Created by Hallie on 7/3/22.
//

import SwiftUI
import Blessed
import SecureXPC

struct FirstTimeHelperView: View {
    @Binding var subtitle: String
    @Binding var canContinue: Bool
    
    @State var hadError: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if !self.hadError {
                Text("Why?")
                    .font(.title2)
                    .bold()
                
                Text("Maple uses a *Privileged Helper Tool* to do things like Library Injection(aka. how Maple changes functionality). Privileged Helper Tools are able to run code with super-user permissions to do things that normal code cannot. Because of this, you need your administrator's password to install it.")
                    .padding(.bottom)
                
                Text("What does the Helper do?")
                    .font(.title2)
                    .bold()
                
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                    Text("Install Maple's Injection Library Executable")
                }
                
                Button {
                    if let github = URL(string: "https://github.com/ha1lie/Maple-LibInjector") {
                        NSWorkspace.shared.open(github)
                    }
                } label: {
                    HStack {
                        Text("Check for yourself on GitHub")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                    }.foregroundColor(.accentColor)
                }.buttonStyle(PlainButtonStyle())
                    .padding(.leading, 20)
                
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                    Text("Run the injection executable")
                }
                
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                    Text("Kill running processes which belong to the super user")
                }
                
                HStack {
                    Spacer()
                    MapleButton(action: {
                        do {
                            try LaunchdManager.authorizeAndBless(message: "Do you want to install the sample helper tool?")
                        } catch AuthorizationError.canceled {
                            ()
                        } catch {
                            self.hadError = true
                            return
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
            self.subtitle = "Installed Maple's Helper Tool"
            self.canContinue = false
        }
    }
}
