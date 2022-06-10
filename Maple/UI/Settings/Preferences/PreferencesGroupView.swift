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
                .font(.title)
                .bold()
            if let _ = self.group.description {
                Text(self.group.description!)
                    .font(.headline)
//                    .font(.system(size: 14))
                
            }
            
            if let _ = self.group.preferences {
                ForEach(0..<self.group.preferences!.count, id: \.self) { i in
                    PreferenceView(preference: self.group.preferences![i])
                }
            }
        }
    }
}
