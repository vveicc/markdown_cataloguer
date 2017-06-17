//
//  MainWindowController.swift
//  MarkdownCataloguer
//
//  Created by VCC on 2017/6/17.
//  Copyright © 2017年 vveicc. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.titlebarAppearsTransparent = true
        window?.contentView?.superview?.subviews[1].subviews.last?.subviews[1].isHidden = true
        window?.contentView?.superview?.subviews[1].subviews.last?.subviews[2].isHidden = true
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        NSApp.terminate(self)
        return true
    }

}
