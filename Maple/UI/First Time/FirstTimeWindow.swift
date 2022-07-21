//
//  FirstTimeWindow.swift
//  Maple
//
//  Created by Hallie on 7/3/22.
//

import SwiftUI

struct FirstTimeWindow: View {
    @State var subtitle: String = ""
    
    @State var openView: Int = 0
    
    @State var views: [AnyView] = []
    
    @State var canContinue: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Welcome")
                    .font(.title)
                    .bold()
                Text(self.subtitle)
                    .font(.title2)
                    .bold()
                
                Divider()
                    .padding(.horizontal)
            }.padding([.top, .horizontal])
            
            ScrollView(.vertical, showsIndicators: true) {
                if self.views.count > 0 {
                    self.views[self.openView]
                        .padding()
                } else {
                    Spacer()
                }
            }
            
            HStack {
                Spacer()
                
                if self.openView > 0 {
                    MapleButton(action: {
                        withAnimation {
                            self.openView -= 1
                        }
                    }, title: "Back", andSize: .small)
                }
                
                MapleButton(action: {
                    if self.openView < 3 {
                        withAnimation {
                            self.openView += 1
                        }
                    } else {
                        self.finalize()
                    }
                }, title: self.openView == 3 ? "Complete Welcome" : "Next", andSize: .small)
                .disabled(!self.canContinue)
            }.padding([.bottom, .horizontal])
        }.onAppear {
            self.views = [
                AnyView(FirstTimeOrientationView(subtitle: self.$subtitle)),
                AnyView(FirstTimeHelperView(subtitle: self.$subtitle, canContinue: self.$canContinue)),
                AnyView(FirstTimeInjectorView(subtitle: self.$subtitle, canContinue: self.$canContinue)),
                AnyView(FirstTimeFinalView(subtitle: self.$subtitle, finalize: {
                    self.finalize()
                }))
            ]
        }
    }
    
    func finalize() {
        MaplePreferencesController.shared.completeWelcome()
        MapleController.shared.closeInstallWindow()
    }
}
