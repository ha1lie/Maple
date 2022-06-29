//
//  InstallVerifyView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallVerifyView: View {
    
    //This view is responsible for displaying the process of installing, and verifying that it only hooks things the user wants it to!
    
    @Binding var completed: Bool
    @Binding var title: String
    @Binding var fileName: URL?
    @Binding var leaf: Leaf?
    @Binding var foundError: String?
    
    @State var statusStrings: [String] = []
    @State var statusSuccess: [Bool?] = []
    @State var successfulCompletion: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if (self.leaf == nil) {
                VStack(alignment: .center) {
                    ProgressView()
                        .progressViewStyle(.linear)
                        .padding()
                    Text("Loading...")
                        .bold()
                        .font(.title)
                    Spacer()
                }
            } else if self.leaf != nil && self.leaf!.isValid() {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        Text("Verify Security")
                            .bold()
                            .font(.title)
                        
                        Text("Great! Now before you install this, we highly recommend that you verify that you trust this Leaf, what it does, and who it's from")
                            .font(.system(size: 14))
                            .padding(.bottom, 6)
                        
                        Text("Due to the nature of Maple, you need to make sure you only install secure software onto your Mac. For some tips and tricks to stay safe, check out Maple's website and security suggestions")
                        Button {
                            if let url = URL(string: "https://google.com") { //TODO: Link to Maple's security page
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text("Maple's Security Page")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14))
                            }.foregroundColor(.accentColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("About this Leaf")
                            .font(.title2)
                            .bold()
                            .padding(.vertical, 6)
                        
                        Group { // Leaf information
                            if let name = self.leaf?.name {
                                Text("**Name:** \(name)")
                            }
                            
                            if let description = self.leaf?.leafDescription {
                                Text("**Description:** \(description)")
                            }
                            
                            if let website = self.leaf?.tweakWebsite {
                                Button {
                                    if let url = URL(string: website) {
                                        NSWorkspace.shared.open(url)
                                    }
                                } label: {
                                    HStack(alignment: .center) {
                                        Text("View tweak's website")
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14))
                                    }.foregroundColor(.accentColor)
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        Group { // Author information
                            if let author = self.leaf?.author {
                                Text("**Author:** \(author)")
                            }
                            
                            if let email = self.leaf?.authorEmail {
                                Text("**Email:** \(email)")
                                Button {
                                    if let emailURL = URL(string: "mailto:\(email)") {
                                        NSWorkspace.shared.open(emailURL)
                                    }
                                } label: {
                                    HStack(alignment: .center) {
                                        Text("Send an email")
                                    }.foregroundColor(.accentColor)
                                }.buttonStyle(PlainButtonStyle())
                            }
                            
                            if let discord = self.leaf?.authorDiscord {
                                Text("**Author's Discord:** \(discord)")
                            }
                        }
                        
                        //Author discord
                        
                        Group { // Injection information
                            if let libraryName = self.leaf?.libraryName {
                                Text("**Library name:** \(libraryName)")
                            }
                            
                            ForEach(Array(self.leaf!.targetBundleID!.enumerated()), id: \.element) { i, _ in // Only forcing positive here so that it will enumerate
                                if let targetBID = self.leaf?.targetBundleID?[i] {
                                    Text("**Target BID:** \(targetBID)")
                                }
                            }
                        }
                    }
                }
            } else if let _ = self.foundError {
                ScrollView {
                    Text("ERROR")
                        .foregroundColor(.red)
                        .font(.title)
                        .bold()
                    Text(self.foundError!)
                        .foregroundColor(.red)
                }
            } else {
                HStack {
                    // Icons
                    Text("Failed to parse this Leaf, you can't install it 😔")
                }
            }
        }.onAppear {
            self.completed = false
            self.title = "Verify your Leaf package"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let _ = self.fileName else {
                    self.completed = false
                    return
                }
                
                do {
                    self.leaf = try MapleController.shared.createLeaf(self.fileName!)
                    self.completed = self.leaf != nil
                } catch {
                    self.completed = true // TODO: Also make this display an error!
                    self.foundError = "\(error)"
                }
            }
        }
    }
}
