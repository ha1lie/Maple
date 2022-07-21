//
//  CustomColorView.swift
//  Maple
//
//  Created by Hallie on 7/2/22.
//

import SwiftUI

struct CustomColorView: View {
    @Binding var selectedColor: Color
    @State var redValue: CGFloat = .random(in: 0...255)
    @State var greenValue: CGFloat = .random(in: 0...255)
    @State var blueValue: CGFloat = .random(in: 0...255)
    
    @State var hexString: String = ""
    
    @State var redString: String = ""
    @State var greenString: String = ""
    @State var blueString: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Red")
                .font(.system(size: 14))
                .bold()
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: self.redValue / 255, green: 0.0, blue: 0.0))
                Slider(value: self.$redValue, in: 0...255)
                MapleTextField(title: "Red", value: self.$redString) {
                    if let n = NumberFormatter().number(from: self.redString) {
                        self.redValue = CGFloat(truncating: n)
                    }
                    self.redString = "\(redValue)"
                }.frame(width: 50)
            }
            
            Text("Green")
                .font(.system(size: 14))
                .bold()
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 0.0, green: self.greenValue / 255, blue: 0.0))
                Slider(value: self.$greenValue, in: 0...255)
                MapleTextField(title: "Green", value: self.$greenString) {
                    if let n = NumberFormatter().number(from: self.greenString) {
                        self.greenValue = CGFloat(truncating: n)
                    }
                    self.greenString = "\(redValue)"
                }.frame(width: 50)
            }
            
            Text("Blue")
                .font(.system(size: 14))
                .bold()
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 0.0, green: 0.0, blue: self.blueValue / 255))
                Slider(value: self.$blueValue, in: 0...255)
                MapleTextField(title: "Blue", value: self.$blueString) {
                    if let n = NumberFormatter().number(from: self.blueString) {
                        self.blueValue = CGFloat(truncating: n)
                    }
                    self.blueString = "\(redValue)"
                }.frame(width: 50)
            }
            
            MapleTextField(title: "Hex", value: self.$hexString) {
                if let color = Color.fromHex(self.hexString) {
                    self.selectedColor = color
                }
            }
            
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 40)
                    .foregroundColor(self.selectedColor)
            }
        }.onAppear {
            self.redValue = self.selectedColor.redValue * 255
            self.greenValue = self.selectedColor.greenValue * 255
            self.blueValue = self.selectedColor.blueValue * 255
            self.hexString = self.selectedColor.toHexString()
        }.onChange(of: self.redValue) { _ in
            self.selectedColor = Color(red: self.redValue / 255, green: self.greenValue / 255, blue: self.blueValue / 255)
            self.redString = "\(Int(self.redValue))"
            self.hexString = self.selectedColor.toHexString()
        }.onChange(of: self.blueValue) { _ in
            self.selectedColor = Color(red: self.redValue / 255, green: self.greenValue / 255, blue: self.blueValue / 255)
            self.greenString = "\(Int(self.greenValue))"
            self.hexString = self.selectedColor.toHexString()
        }.onChange(of: self.greenValue) { _ in
            self.selectedColor = Color(red: self.redValue / 255, green: self.greenValue / 255, blue: self.blueValue / 255)
            self.blueString = "\(Int(self.blueValue))"
            self.hexString = self.selectedColor.toHexString()
        }
    }
}
