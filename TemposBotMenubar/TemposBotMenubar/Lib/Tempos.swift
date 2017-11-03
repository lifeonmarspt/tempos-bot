//
//  Tempos.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 03/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class Tempos {

  static func projects() -> Array<String> {
    let fileManager = FileManager.default
    let defaultRepo = UserDefaults.standard.string(forKey: "repo")!

    let regex = try! NSRegularExpression(pattern: "\\w+\\/\\w+", options: .caseInsensitive)
    
    var files = fileManager.subpaths(atPath: defaultRepo)!
    files = files.filter {
      !$0.starts(with: ".git") &&
      regex.numberOfMatches(in: $0, range: NSMakeRange(0, $0.utf16.count)) == 1
    }
    
    return files
  }
}
