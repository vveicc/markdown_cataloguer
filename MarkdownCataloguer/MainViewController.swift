//
//  ViewController.swift
//  MarkdownCataloguer
//
//  Created by 魏川程 on 2017/6/7.
//  Copyright © 2017年 vveicc. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var dragView: MCDragView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragView.receiveFile = { filePath in
            self.handleAndSaveFile(filePath: filePath)
        }
    }

    @IBAction func addFileButtonAction(_ sender: MCButton) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowedFileTypes = ["md", "MD", "mD", "Md"]
        panel.begin { (response: NSModalResponse) in
            if response == NSModalResponseOK {
                let path = panel.urls.first!.path
                print("OpenPath: \(path)")
                self.handleAndSaveFile(filePath: path)
            }
        }
    }
    
    func handleAndSaveFile(filePath: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { 
            guard let content = MCHelper.shared.handleMarkdownFile(filePath: filePath) else {
                return
            }
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.canSelectHiddenExtension = false
            panel.isExtensionHidden = false
            panel.allowedFileTypes = ["md"]
            panel.nameFieldStringValue = filePath.components(separatedBy: "/").last!
            panel.begin { (response: NSModalResponse) in
                if response == NSModalResponseOK {
                    let path = panel.url!.path
                    print("SavePath: \(path)")
                    do {
                        try content.write(toFile: path, atomically: true, encoding: .utf8)
                    } catch {
                        print("保存文件失败！！！")
                    }
                }
            }
        }
    }

}

