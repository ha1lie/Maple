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
        VStack {
            if (self.leaf == nil) {
                HStack {
                    // Spinnyyyyyyy
                    Text("Loading...")
                        .bold()
                        .font(.title)
                }
            } else if self.leaf != nil && self.leaf!.isValid() {
                ScrollView(.vertical, showsIndicators: true) {
                    Text("Verify Security")
                        .bold()
                        .font(.title)
                    Text("Below is a list of functions which are modified by the selected package. Please ensure you trust the source(listed at the bottom) and that it is not modifying any suspicious behavior")
                        .font(.body)
                    Text("*Name*: " + (self.leaf!.name ?? "NAME"))
                    Text("*Author*: " + (self.leaf!.author ?? "AUTHOR"))
                    Text("*Library name*: " + (self.leaf!.libraryName ?? "LIBRARY NAME"))
                    Text("*Target BID*: " + (self.leaf!.targetBundleID ?? "TARGET BID"))
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                guard let _ = self.fileName else {
                    self.completed = false
                    return
                }
                do {
                    self.leaf = try MapleController.shared.installFile(self.fileName!)
                    self.completed = self.leaf != nil
                } catch {
                    self.completed = true // TODO: Also make this display an error!
                    self.foundError = "\(error)"
                }
            }
        }
    }
}
