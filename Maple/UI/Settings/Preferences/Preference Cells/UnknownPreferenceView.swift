//
//  UnknownPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/9/22.
//

import SwiftUI
import MapleKit

struct UnknownPreferenceView<P: Preference>: View {
    let preference: P
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
            Text("Unknown preference mystery type")
                .bold()
        }.foregroundColor(.red)
        .padding(.bottom)
    }
}
