//
//  Maple+Color.swift
//  Maple
//
//  Created by Hallie on 7/2/22.
//

import SwiftUI

extension Color {
    /// Forcefully create a non-optional CGColor
    public var _cgColor: CGColor {
        return NSColor(self).cgColor
    }
    
    /// Red value of self
    public var redValue: CGFloat {
        return self._cgColor.components?[0] ?? 0
    }
    
    /// Green value of self
    public var greenValue: CGFloat {
        return self._cgColor.components?[1] ?? 0
    }
    
    /// Blue value of self
    public var blueValue: CGFloat {
        return self._cgColor.components?[2] ?? 0
    }
    
    public func toHexString() -> String {
        String.init(format: "#%02lX%02lX%02lX", lroundf(Float(self.redValue * 255)), lroundf(Float(self.greenValue * 255)), lroundf(Float(self.blueValue * 255)))
    }
    
    /// Creates Color object from hex string
    /// - Parameter hex: Hex representation in String form
    /// - Returns: Color if possible to create
    public static func fromHex(_ hex: String) -> Color? {
        // Modified from https://stackoverflow.com/a/56874327
        var hexString = ""
        for ch in hex {
            if let _ = ch.hexDigitValue {
                hexString = "\(hexString)\(String(ch))"
            }
        }
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        return self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
