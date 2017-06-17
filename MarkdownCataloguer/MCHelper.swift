//
//  MCHelper.swift
//  MarkdownCataloguer
//
//  Created by VCC on 2017/6/12.
//  Copyright © 2017年 vveicc. All rights reserved.
//

import Cocoa

final class MCHelper: NSObject {
    
    static let shared = MCHelper()
    
    private override init() {
        super.init()
    }
    
    var original = [String]()
    var titles = [(row: Int, level: Int, title: String)]()
    var subtitles = [(row: Int, level: Int, title: String)]()
    
    var catalogStartRow = 0
    var catalogStartLevel = 2
    var startLevelTitleRow = 0
    
    func handleMarkdownFile(filePath: String) -> String? {
        guard let content = try? String(contentsOfFile: filePath) else {
            print("读取文件失败！！！")
            return nil
        }
        original = content.components(separatedBy: CharacterSet.newlines)
        
        var isCode = false
        for row in 0..<original.count {
            if original[row].hasPrefix("```") {
                isCode = !isCode
            } else if !isCode && original[row].hasPrefix("#") {
                if let (level, title) = handleTitle(title: original[row]) {
                    titles.append((row, level, title))
                }
            }
        }
        
        configCatalog()
        
        if catalogStartLevel < startLevelTitleRow {
            generateCatalog()
        }
        return original.reduce("", { (content, line) -> String in
            content + line + "\n"
        })
    }
    
    func generateCatalog() {
        let catalog = subtitles.reduce("\n\n\n# 目录\n\n") { (catalog, title) -> String in
            catalog + (title.level == catalogStartLevel ? "\n" : "")
                + String(repeating: " ", count: title.level == catalogStartLevel ? 0 : ((title.level - catalogStartLevel) * 3 - 1))
                + "- [" + title.title + "]"
                + "(" + generateTitleUrl(title: title.title) + ")"
                + "\n"
        }
        original[(catalogStartLevel + 1)..<startLevelTitleRow] = [catalog + "\n\n"]
    }
    
    func generateTitleUrl(title: String) -> String {
        var url = "#"
        for (_, value) in title.lowercased().characters.enumerated() {
            if (value >= "\u{4E00}" && value <= "\u{9FA5}")
                || (value >= "a" && value <= "z")
                || (value >= "0" && value <= "9") {
                url.append(value)
            } else if value == Character(" ") {
                url.append("-")
            }
        }
        return url
    }
    
    func configCatalog() {
        let doctitles = Array(titles.filter { $0.level < catalogStartLevel })
        if doctitles.count > 0 { catalogStartRow = doctitles.last!.row + 1 }
        subtitles = Array(titles.filter { $0.level >= catalogStartLevel })
        if subtitles.count > 0 { startLevelTitleRow = subtitles.first!.row }
    }
    
    func handleTitle(title: String) -> (Int, String)? {
        guard title.hasPrefix("#") && title.characters.count > 1 else {
            return nil
        }
        var level = 1
        while title.substring(with: title.index(title.startIndex, offsetBy: level)..<title.index(title.startIndex, offsetBy: level + 1)) == "#" && level < title.characters.count {
            level += 1
        }
        if level == title.characters.count {
            level -= 1
        }
        return (level, title.substring(from: title.index(title.startIndex, offsetBy: level)).trimmingCharacters(in: CharacterSet.whitespaces))
    }
}





