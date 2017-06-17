//
//  MCButton.swift
//  MarkdownCataloguer
//
//  Created by VCC on 2017/6/17.
//  Copyright © 2017年 vveicc. All rights reserved.
//

import Cocoa

class MCButton: NSButton {
    
    var mouseIn = false
    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        (cell as! NSButtonCell).highlightsBy = NSCellStyleMask(rawValue: 0)
        mouseIn = false
        isBordered = false
        isHighlighted = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        (cell as! NSButtonCell).highlightsBy = NSCellStyleMask(rawValue: 0)
        mouseIn = false
        isBordered = false
        isHighlighted = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func updateTrackingAreas() {
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil))
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseIn = true
        updateImage()
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseIn = false
        updateImage()
    }
    
    func updateImage() {
        if isHighlighted || mouseIn {
            image = #imageLiteral(resourceName: "add_file_track")
        } else {
            image = #imageLiteral(resourceName: "add_file")
        }
    }
    
}
