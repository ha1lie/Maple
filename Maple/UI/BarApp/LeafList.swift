//
//  LeafList.swift
//  Maple
//
//  Created by Hallie on 4/15/22.
//

import SwiftUI

struct LeafList: View {
    
    @ObservedObject var mapleController: MapleController = .shared
    
    @Binding var selectedLeaf: Leaf?
    
    var body: some View {
        VStack {
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
                            LeafCell(leaf, withSelected: self.$selectedLeaf)
                        }
                    }
                }
                
                Spacer()
                
                if self.mapleController.canCurrentlyInject {
                    // Icon
                    Text("Configured Properly")
                        .foregroundColor(.gray)
                } else {
                    Button {
                        print("PLEASE SHOW A WINDOW TO BE ABLE TO CONFIGURE THINGS PROPERLY")
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            
                            Text("Error with configuration")
                                .foregroundColor(.red)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
            }.padding()
        }
    }
}
