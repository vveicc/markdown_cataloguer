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
    @IBOutlet weak var addFileButton: MCButton!
    @IBOutlet weak var msgTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragView.receiveFile = { filePath in
            self.processAnimating(filePath: filePath)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        dragView.addFileButtonFrame = addFileButton.frame
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
                self.processAnimating(filePath: path)
            }
        }
    }
    
    func processAnimating(filePath: String) {
        addFileButton.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer: Timer) in
            self.dragView.progress += 2
            if self.dragView.progress == 100 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: { 
                    self.handleAndSaveFile(filePath: filePath)
                    self.dragView.progress = 0
                })
            }
        }
    }
    
    func handleAndSaveFile(filePath: String) {
        guard let content = MCHelper.shared.handleMarkdownFile(filePath: filePath) else {
            return
        }
        print("content: \n\(content)")
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
            self.addFileButton.isEnabled = true
        }
    }

}

