//
//  MapleDialogue.swift
//  Maple
//
//  Created by Hallie on 5/24/22.
//

import SwiftUI

struct MapleDialogue: View {
    
    let title: String
    let contents: String
    let options: [String]
    
    let resultSema = DispatchSemaphore(value: 0)
    
    @State var size: NSSize?
    @State var chosen: String = ""
    
    public func getSize() -> NSSize {
        return self.size ?? NSSize(width: 300, height: 200)
    }
    
    public func getResult() -> String {
        resultSema.wait()
        return self.chosen
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(.windowBackgroundColor))
                .frame(width: 300)
            
            VStack(alignment: .leading) {
                Text(self.title)
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 6)
                Text(self.contents)
                    .padding(.bottom, 6)
                HStack {
                    ForEach(self.options, id: \.self) { option in
                        Button {
                            self.chosen = option
                            self.resultSema.signal()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 40)
                                    .foregroundColor(.blue)
                                Text(option)
                                    .font(.system(size: 14))
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }.padding()
        }
    }
}
