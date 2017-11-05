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
    let defaultRepo = UserDefaults.standard.string(forKey: "repo")
    
    if defaultRepo == nil { return [] }

    let regex = try! NSRegularExpression(
      pattern: "^[-\\w]+\\/[-\\w]+$",
      options: .caseInsensitive
    )

    var paths = fileManager.subpaths(atPath: defaultRepo!) ?? []

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

  static func runCommand(_ command: String) {
  }

  static func status(_ project: String) -> String {
    let path = projectPath(project)
    do {
      let content = try String(contentsOfFile: path)
      let status = content
        .split(separator: "\n")
        .reversed()
        .first(where: {
          $0.contains("start") || $0.contains("stop")
        })

      // empty file
      if (status == nil) {
        return "stop"
      }

      return status!.contains("stop") ? "stop" : "start"
    }
    catch {
      let file = FileManager.default.createFile(atPath: path, contents: nil)

      print("created file \(file)")
      return "stop"
    }
  }

  static func start(_ project: String) {
    if status(project) == "start" { return }
    writeCommand(project, command: "start")
  }

  static func stop(_ project: String) {
    if status(project) == "stop" { return }
    writeCommand(project, command: "stop")
  }

  private static func writeCommand(_ project: String, command: String) {
    let file = FileHandle(forWritingAtPath: projectPath(project))
    let log = "\(Int(NSDate().timeIntervalSince1970)) \(timezone()) \(command)\n"

    file?.seekToEndOfFile()
    file?.write(log.data(using: .utf8)!)
    file?.closeFile()
  }

  private static func projectPath(_ project: String) -> String {
    let location = "\(UserDefaults.standard.string(forKey: "repo")!)/\(project)/\(Git.commiter())"
    return location.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func timezone() -> String {
    // readlink /etc/localtime | cut -d "/" -f "5,6"

    let task = Process()
    task.launchPath = "/usr/bin/readlink"
    task.arguments = ["/etc/localtime"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let handle = pipe.fileHandleForReading
    let data = handle.readDataToEndOfFile()

    task.waitUntilExit()
    let tzParts = String(data: data, encoding: .utf8)!.split(separator: "/")
    let tzRange = tzParts.index(tzParts.endIndex, offsetBy: -2) ..< tzParts.endIndex
    let tz = tzParts[tzRange].joined(separator: "/").trimmingCharacters(in: .whitespacesAndNewlines)

    return tz
  }
}
