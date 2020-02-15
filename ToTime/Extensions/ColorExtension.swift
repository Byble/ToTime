//
//  ColorExtension.swift
//  ToTime
//
//  Created by 김민국 on 2020/02/10.
//  Copyright © 2020 김민국. All rights reserved.
//

import Foundation
import SwiftUI

extension UIColor{
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    public convenience init?(hex: String) {
            let r, g, b, a: CGFloat

            if hex.hasPrefix("#") {
                let start = hex.index(hex.startIndex, offsetBy: 1)
                let hexColor = String(hex[start...])

                if hexColor.count == 6 {
                    let scanner = Scanner(string: hexColor)
                    var hexNumber: UInt64 = 0

                    if scanner.scanHexInt64(&hexNumber) {
                        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                        b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255
                        a = 1

                        self.init(red: r, green: g, blue: b, alpha: a)
                        return
                    }
                }
            }

            return nil
        }
}

extension Color {
    static let lightBackgroundColor = Color(white: 1.0)

    static let darkBackgroundColor = Color(white: 0.0)

    static func backgroundColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return darkBackgroundColor
        } else {
            return lightBackgroundColor
        }
    }
    
    static func rgb(r: Double, g: Double, b: Double) -> Color {
        return Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
    static let backgroundColor = Color.rgb(r: 21, g: 22, b: 33)
    static let outlineColor = Color.rgb(r: 54, g: 255, b: 203)
    static let trackColor = Color.rgb(r: 45, g: 56, b: 95)
    static let pulsatingColor = Color.rgb(r: 73, g: 113, b: 148)
}

