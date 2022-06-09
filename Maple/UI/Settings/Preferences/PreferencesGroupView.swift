//
//  PreferencesGroupView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI

struct PreferencesGroupView: View {
    let group: PreferenceGroup
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.group.name)
                .font(.system(size: 16, weight: .medium))
            
            Text(self.group.description)
                .font(.system(size: 14))
            
            ForEach(self.group.preferences, id: \.self) { preference in
                PreferenceView(preference: preference)
            }
        }
    }
}
