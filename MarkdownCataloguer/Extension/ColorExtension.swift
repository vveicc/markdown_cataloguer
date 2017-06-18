//
//  ColorExtension.swift
//  MarkdownCataloguer
//
//  Created by VCC on 2017/6/18.
//  Copyright © 2017年 vveicc. All rights reserved.
//

import Cocoa

extension NSColor {
    
    // Init color by hexColorString('[#aa]rrggbb')
    convenience init?(hexColorString colorStr: String) {
        var cStr = colorStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if cStr.hasPrefix("#") {
            cStr = cStr.substring(from: cStr.index(after: cStr.startIndex))
        }
        var components = [String]()
        if cStr.characters.count == 6 || cStr.characters.count == 8 {
            for i in stride(from: 0, to: cStr.characters.count, by: 2) {
                components.append(cStr.substring(with: cStr.index(cStr.startIndex, offsetBy: i)..<cStr.index(cStr.startIndex, offsetBy: i + 2)))
            }
            if components.count == 3 {
                components.insert("ff", at: 0)
            }
            var r: CUnsignedInt = 255
            var g: CUnsignedInt = 255
            var b: CUnsignedInt = 255
            var a: CUnsignedInt = 255
            Scanner(string: components[0]).scanHexInt32(&a)
            Scanner(string: components[1]).scanHexInt32(&r)
            Scanner(string: components[2]).scanHexInt32(&g)
            Scanner(string: components[3]).scanHexInt32(&b)
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        } else {
            fatalError("Illegal hexColorString('\(colorStr)')")
        }
    }
    
}
