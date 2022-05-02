//
//  HelperSettingsView.swift
//  Maple
//
//  Created by Hallie on 5/1/22.
//

import SwiftUI

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
                    print("INSTALL THE HELPER TOOL")
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
}
