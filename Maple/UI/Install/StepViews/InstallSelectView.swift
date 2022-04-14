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
    
    var body: some View {
        VStack {
            Text("Select the proper leaf package")
            
            MapleButton(action: {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.init(exportedAs: "dev.halz.maple.mapleleaf"), .zip]
                if panel.runModal() == .OK {
                    self.fileName = panel.url
                }
                if let _ = self.fileName {
                    self.completed = true
                }
            }, title: "Chose Package File")
            
            Text("Chosen File: " + (self.fileName?.absoluteString ?? "NOFILE"))
            MapleButton(action: {
                self.completed = false
                self.fileName = nil
            }, title: "CLEAR FILE")

        }.onAppear {
            self.completed = self.fileName != nil
            self.title = "Select your Leaf package"
        }
    }
}
