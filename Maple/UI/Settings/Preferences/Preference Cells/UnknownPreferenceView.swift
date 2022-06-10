//
//  UnknownPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/9/22.
//

import SwiftUI

struct UnknownPreferenceView: View {
    let preference: any Preference
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
            Text("Unknown preference mystery type")
                .bold()
        }.foregroundColor(.red)
        .padding(.bottom)
    }
}
