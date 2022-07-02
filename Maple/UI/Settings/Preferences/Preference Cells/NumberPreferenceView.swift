//
//  NumberPreferenceView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

//TODO: This will be implemented at some point in the future
//struct NumberPreferenceView: View {
//    let preference: Preference
//    @State var ignore: Bool = true
//    @State var prefValue: CGFloat = 0.0
//
//    @State var stringNumberValue: String = ""
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(self.preference.name)
//                    .font(.system(size: 14, weight: .bold))
//                if let description = self.preference.description {
//                    Text(description)
//                }
//            }
//
//            Spacer()
//
//
//        }.padding(.bottom)
//        .onAppear {
//            switch self.preference.getValue() {
//            case .number(let value):
//                if let value = value {
//                    self.prefValue = value
//                }
//            default:
//                ()
//            }
//            self.ignore = false
//        }.onChange(of: self.prefValue) { newValue in
//            if !self.ignore {
//                self.preference.setValue(.number(newValue))
//            }
//        }
//    }
//}
