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

    let regex = try! NSRegularExpression(
      pattern: "^[-\\w]+\\/[-\\w]+$",
      options: .caseInsensitive
    )

    var paths = fileManager.subpaths(atPath: defaultRepo)!

    paths = paths.filter {
      !$0.starts(with: ".git") &&
      regex.numberOfMatches(in: $0, range: NSMakeRange(0, $0.utf8.count)) == 1
    }

    return paths
  }

  static func isValidCommand(command: String) -> Bool {
    let regex = try! NSRegularExpression(
      pattern: "^(add|remove)\\s+\\d+(h|h\\d+(m|min)|m|min)$",
      options: .caseInsensitive
    )

    print("Tempos.isValidCommand(\(command))")
    return regex.numberOfMatches(in: command, range: NSMakeRange(0, command.utf8.count)) == 1
  }
}
