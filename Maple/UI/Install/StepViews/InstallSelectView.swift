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
    @Binding var fileName: String
    
    var body: some View {
        VStack {
            Text("Select the proper leaf package")
            
            MapleButton(action: {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.init(exportedAs: "dev.halz.maple.mapleleaf")]
                if panel.runModal() == .OK {
                    self.fileName = panel.url?.absoluteString ?? ""
                    self.fileName = self.fileName.replacingOccurrences(of: "file://", with: "")
                }
                if self.fileName != "" {
                    self.completed = true
                }
            }, title: "Chose Package File")
            
            Text("Chosen File: " + self.fileName)
            MapleButton(action: {
                self.completed = false
                self.fileName = ""
            }, title: "CLEAR FILE")

        }.onAppear {
            self.completed = self.fileName != ""
            self.title = "Select your Leaf package"
        }
    }
}
