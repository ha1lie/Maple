//
//  ContentView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct HomeScreen: View {
    
    private var mapleController: MapleController = .shared
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                HStack {
                    Text("Maple")
                        .font(.title)
                        .bold()
                    Spacer()
                    
                    Button {
                        self.mapleController.openWindowToInstallLeaf()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 60, height: 30)
                                .foregroundColor(.gray)
                            Text("NEW")
                                .bold()
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
                
                if self.mapleController.installedLeaves.count == 0 {
                    Text("You don't have any Leaves installed currently")
                } else {
                    ForEach(self.mapleController.installedLeaves) { leaf in
                        LeafCell(leaf)
                    }
                }
            }.padding()
        }
    }
}
