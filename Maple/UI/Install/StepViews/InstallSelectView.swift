//
//  InstallSelectView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallSelectView: View {
    
    @Binding var completed: Bool
    @Binding var title: String
    @Binding var fileName: URL?
    
    @State var fileDragOver: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                Text("Select your .mapleleaf file")
                    .font(.title2)
                    .bold()
                
                VStack(alignment: .center) {
                    if let fileName = fileName {
                        Group {
                            Text("Chosen File: " + (fileName.lastPathComponent))
                            Button {
                                withAnimation {
                                    self.fileName = nil
                                    self.completed = false
                                }
                            } label: {
                                HStack {
                                    Text("Not right? Clear selection and try again")
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 14))
                                }.foregroundColor(.gray)
                            }.buttonStyle(PlainButtonStyle())
                        }.animation(.easeInOut, value: self.fileName)
                            .transition(.move(edge: .top))
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.fileDragOver ? Color.accentColor : Color.clear, lineWidth: 2)
                            .foregroundColor(.clear)
                        
                        VStack(alignment: .center) {
                            HStack(alignment: .center) {
                                Text("Drag and drop .mapleleaf here")
                                    .bold()
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 14))
                            }.padding(.bottom, 12)
                            
                            Image(systemName: "filemenu.and.selection")
                                .font(.system(size: 20))
                        }.padding()
                    }.background(Color.clear)
                    .onDrop(of: ["public.file-url"], isTargeted: self.$fileDragOver) { providers, location in //TODO: Make sure this can only import a .mapleleaf file
                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, error in
                            if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
                                withAnimation {
                                    self.fileName = url
                                    self.completed = self.fileName != nil
                                }
                            }
                        })
                        return true
                    }
                    
                    Button {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        panel.allowedContentTypes = [.init(exportedAs: "dev.halz.maple.mapleleaf"), .zip]
                        if panel.runModal() == .OK {
                            withAnimation {
                                self.fileName = panel.url
                            }
                        }
                        if let _ = self.fileName {
                            self.completed = true
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Text("Select with Finder instead")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14))
                        }.foregroundColor(.gray)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }.onAppear {
            self.completed = self.fileName != nil
            self.title = "Select your Leaf package"
        }
    }
}
