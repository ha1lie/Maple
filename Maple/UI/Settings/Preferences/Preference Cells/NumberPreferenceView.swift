//
//  NumberPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MapleKit

struct NumberPreferenceView: View {
    let preference: Preference
    @State var ignore: Bool = true
    @State var value: String = ""
    @State var numValue: CGFloat = 0.0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.preference.name)
                    .font(.system(size: 14, weight: .bold))
                
                if let description = self.preference.description {
                    Text(description)
                }
            }
            Spacer()
            MapleTextField(title: self.preference.name, value: self.$value, onSubmit: {
                if let n = NumberFormatter().number(from: self.value) {
                    self.numValue = CGFloat(truncating: n)
                }
                self.value = "\(Int(self.numValue))"
            }).frame(width: 100)
        }.padding(.bottom)
        .onAppear {
            switch self.preference.getValue() {
            case .number(let numberValue):
                if let numberValue = numberValue {
                    self.numValue = numberValue
                    self.value = "\(Int(self.numValue))"
                }
            default:
                ()
            }
            self.ignore = false
        }.onChange(of: self.numValue) { newValue in
            if !self.ignore {
                self.preference.setValue(.number(newValue))
            }
        }
    }
}
