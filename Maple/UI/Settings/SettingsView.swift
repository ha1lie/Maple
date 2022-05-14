//
//  SettingsView.swift
//  Maple
//
//  Created by Hallie on 5/1/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                HStack {
                    Text("Settings")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                HelperSettingsView()
            }
        }.padding()
    }
}
