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
}
