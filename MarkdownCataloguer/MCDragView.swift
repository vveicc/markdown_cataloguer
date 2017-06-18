//
//  MCDragView.swift
//  MarkdownCataloguer
//
//  Created by 魏川程 on 2017/6/7.
//  Copyright © 2017年 vveicc. All rights reserved.
//

import Cocoa

class MCDragView: NSView {
    
    var hasDragIn: Bool = false
    var receiveFile: ((_ filePath: String) -> ())?
    
    var addFileButtonWidth: CGFloat?
    var addFileButtonCenter: NSPoint?
    var addFileButtonFrame: NSRect? {
        
        didSet {
            if let buttonFrame = addFileButtonFrame {
                addFileButtonWidth = buttonFrame.size.width
                addFileButtonCenter = NSPoint(x: buttonFrame.origin.x + addFileButtonWidth! / 2, y: buttonFrame.origin.y + addFileButtonWidth! / 2)
            }
        }
    }
    
    var progress: CGFloat = 0 {
        
        didSet {
            if progress < 0 || progress > 100 {
                progress = 0
            }
            needsDisplay = true
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        register(forDraggedTypes: [NSFilenamesPboardType])
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.white.set()
        let path = NSBezierPath()
        path.appendRect(dirtyRect)
        path.fill()
        
        if let _ = addFileButtonFrame {
            NSColor(hexColorString: "278CFB")!.set()
            let arcPath = NSBezierPath()
            arcPath.lineWidth = 1.6
            arcPath.lineCapStyle = .roundLineCapStyle
            arcPath.lineJoinStyle = .roundLineJoinStyle
            arcPath.appendArc(withCenter: addFileButtonCenter!, radius: addFileButtonWidth! / 2 + 3.4, startAngle: 90, endAngle: -360 * progress / 100 + 90, clockwise: true)
            arcPath.stroke()
        }
    }
    
    // MARK: - NSDraggingDestination
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        hasDragIn = true
        needsDisplay = true
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        hasDragIn = false
        needsDisplay = true
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        hasDragIn = false
        needsDisplay = true
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let propertyList = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? Array<String>
        if let propertyList = propertyList,
            propertyList.count == 1,
            let filePath = propertyList.first,
            filePath.characters.count > 3 {
            Swift.print("MCDragView ---> performDragOperation, filePath: \(filePath)")
            if filePath.substring(from: filePath.index(filePath.endIndex, offsetBy: -3)).lowercased() == ".md" {
                if let receiveFile = receiveFile {
                    receiveFile(filePath)
                }
            }
        } else {
            Swift.print("MCDragView ---> performDragOperation, propertyList:", propertyList ?? "nil")
        }
        return true
    }
    
}





