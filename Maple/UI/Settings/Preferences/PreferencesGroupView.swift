//
//  PreferencesGroupView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct PreferencesGroupView: View {
    @ObservedObject var group: PreferenceGroup
    
    var body: some View {
        VStack(alignment: .leading) {
            if self.group.canShow {
                Text(self.group.name)
                    .font(.title)
                    .bold()
                if let _ = self.group.description {
                    Text(self.group.description!)
                        .font(.headline)
                }
                
                if let _ = self.group.preferences {
                    ForEach(0..<self.group.preferences!.count, id: \.self) { i in
                        PreferenceView(preference: self.group.preferences![i])
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}
