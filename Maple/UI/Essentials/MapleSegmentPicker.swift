//
//  MapleSegmentPicker.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI

struct MapleSegmentPicker: View {
    let options: [String]
    
    @Binding var value: Int
    
    init(withOptions options: [String], andValue val: Binding<Int>) {
        self.options = options
        self._value = val
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(nsColor: .darkGray))
            HStack {
                ForEach(self.options, id: \.self) { option in
                    ZStack {
                        if self.options[self.value] == option {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.blue)
                                .padding(2)
                        }
                        HStack {
                            Spacer()
                            Text(option)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                        }
                        RoundedRectangle(cornerRadius: 0)
                            .onTapGesture {
                                self.value = self.options.firstIndex(of: option) ?? self.value
                            }
                    }
                }
            }
        }.frame(height: 36)
    }
}
