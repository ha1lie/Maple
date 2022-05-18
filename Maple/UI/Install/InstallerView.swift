//
//  InstallerView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallerView: View {
    @State var stepNum: Int = 0
    @State var canContinue: Bool = false
    @State var currentTitle: String = ""
    @State var chosenPackageName: URL? = nil
    @State var leaf: Leaf? = nil
    @State var error: String? = nil
    @State var views: [AnyView] = [AnyView(EmptyView())]
    
    var body: some View {
        VStack {
            Text("Leaf Installer: Step #\(self.stepNum)")
                .font(.title)
                .bold()
            Text(self.currentTitle)
            
            Spacer() // This is where the content of each step will go, gotta figure out the best way to do that first
            
            if let _ = self.error {
                ScrollView {
                    Text("Oops!")
                        .bold()
                        .font(.title)
                    Text("We couldn't install your leaf currently, we had an error we couldn't fix.")
                    Text("Error: \(self.error!)")
                        .foregroundColor(.red)
                }
            } else {
                self.views[self.stepNum]
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                MapleButton(action: {
                    if (self.stepNum != 0) {
                        self.stepNum -= 1
                    }
                }, title: "BACK").disabled(self.stepNum == 0)
                
                MapleButton(action: {
                    if self.stepNum != 3 {
                        self.stepNum += 1
                    } else {
                        // Close the window
                        MapleController.shared.closeInstallWindow()
                    }
                }, title: self.stepNum != 3 && self.error == nil ? "NEXT" : "FINISH").disabled(!self.canContinue)
            }
        }.padding()
        .onAppear {
            self.views = [
                AnyView(InstallWelcomeView(completed: $canContinue, title: $currentTitle)),
                AnyView(InstallSelectView(completed: $canContinue, title: $currentTitle, fileName: $chosenPackageName)),
                AnyView(InstallVerifyView(completed: $canContinue, title: $currentTitle, fileName: $chosenPackageName, leaf: $leaf, foundError: self.$error)),
                AnyView(InstallStartView(complete: $canContinue, title: $currentTitle, leaf: $leaf))
            ]
        }
    }
}
