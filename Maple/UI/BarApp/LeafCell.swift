//
//  LeafCell.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct LeafCell: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                Text("Smooth Bar")
                    .bold()
                Text("Move your volume out of 2007")
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
    }
}
