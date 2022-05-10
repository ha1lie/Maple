//
//  HelperSettingsView.swift
//  Maple
//
//  Created by Hallie on 5/1/22.
//

import SwiftUI
import Blessed
import SecureXPC
import EmbeddedPropertyList

struct HelperSettingsView: View {
    var body: some View {
        VStack {
            Text("Helper Tool")
                .font(.title2)
                .bold()
            Text("Version: ???")
            Text("Installed: NOPE")
            HStack(spacing: 8) {
                Button {
                    self.installHelper()
                } label: {
                    Text("Install")
                }

                Button {
                    print("UPDATE THE HELPER TOOL")
                } label: {
                    Text("Update")
                }

                Button {
                    print("UNINSTALL THE HELPER TOOL")
                } label: {
                    Text("Uninstall")
                }
                
                Button {
                    DiagnosticSigningInfo.printDiagnosticInfo()
                } label: {
                    Text("PRINT DIAGNOSTIC")
                }
                
                Button {
                    self.writeToLibrary()
                } label: {
                    Text("Library Ownership")
                }
            }
        }
    }
    
    private func installHelper() {
        print("Installing the helper")
        do {
            try LaunchdManager.authorizeAndBless(message: "Do you want to install the sample helper tool?")
        } catch AuthorizationError.canceled {
            // No user feedback needed, user canceled
            print("User canceled the install")
        } catch {
            print("Failed to instal the helper: \(error.localizedDescription)")
        }
        print("Finished installing the helper")
    }
    
    private func writeToLibrary() {
        print("Going to try to write to /Library/PrivilegedHelperTools")
        let d = Data("I CAN WRITE HAHA".utf8)
        if FileManager.default.createFile(atPath: "/Library/PrivilegedHelperTools/magic", contents: d) {
            print("Successfully wrote the file!")
        } else {
            print("Okay this is probably why we can't write here")
        }
    }
}
