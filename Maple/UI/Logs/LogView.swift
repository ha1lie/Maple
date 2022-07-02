//
//  LogView.swift
//  Maple
//
//  Created by Hallie on 6/26/22.
//

import SwiftUI

struct LogView: View {
    @Binding var highLightedLog: Log?
    let log: Log
    
    var logColor: Color {
        get {
            switch self.log.type {
            case .normal :
                return .primary
            case .warning:
                return .yellow
            case .error:
                return .red
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(self.log == self.highLightedLog ? .accentColor : .clear)
            
            HStack {
                Group {
                    Text(self.log.time)
                        .padding(.horizontal)
                    Text(self.log.bundle)
                        .padding(.trailing)
                    Text(self.log.log)
                        .padding(.trailing)
                        .lineLimit(1)
                        .help(self.log.log)
                }.foregroundColor(self.log == self.highLightedLog ? .white : self.logColor)
                
                Spacer()
            }.padding(.vertical, 2)
        }
    }
}
