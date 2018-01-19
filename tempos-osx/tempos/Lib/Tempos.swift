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

  static func createProject(path: String) -> Bool {
    let regex = try! NSRegularExpression(
      pattern: "^[-\\w]+\\/[-\\w]+$",
      options: .caseInsensitive
    )
    
    if regex.numberOfMatches(in: path, range: NSMakeRange(0, path.utf8.count)) != 1 {
      return false
    }
    
    let fileManager = FileManager.default
    let defaultRepo = UserDefaults.standard.string(forKey: "repo")!
    
    do {
      try fileManager.createDirectory(
        atPath: "\(defaultRepo)/\(path)",
        withIntermediateDirectories: true,
        attributes: nil
      )
      return true
    }
    catch {
      return false
    }
  }

  static func isValidCommand(command: String) -> Bool {
    let regex = try! NSRegularExpression(
      pattern: "^(add|remove)\\s+\\d+(h|h\\d+(m|min)|m|min)$",
      options: .caseInsensitive
    )

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
      return "stop"
    }
  }

  static func globalStatus() -> String {
    var ret = "stop"
    projects().forEach{ if status($0) == "start" { ret = "start" } }
    return ret
  }

  static func report(_ project: String) -> String {
    let file = FileHandle(forReadingAtPath: projectPath(project))
    let data = file?.readDataToEndOfFile()

    if data == nil { return " --:-- " }

    let commands = String(data: data!, encoding: .utf8)!
    if commands.isEmpty { return " --:-- " }

    var seconds = commands
      .split(separator: "\n")
      .filter{
        if $0.starts(with: "#") { return false }

        let timestamp = Double($0.split(separator: " ")[0])!
        let date = Date(timeIntervalSince1970: timestamp)

        return NSCalendar.current.isDateInToday(date)
      }
      .reduce(0, { total, command in
        if command.contains("start") || command.contains("stop") {
          let timestamp = Int(command.split(separator: " ")[0])!

          return timestamp - total
        }

        return total
      })

    // if seconds is longer than a day, then the last command was a start
    // and the current value is somewhere around today, so we subtract it
    // from the current date to create a soft "stop" command
    if seconds > 86400 {
      seconds = Int(Date().timeIntervalSince1970) - seconds
    }

    let spentDate = Date(timeIntervalSince1970: Double(seconds))
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(abbreviation: "UTC")

    return formatter.string(from: spentDate)
  }

  static func start(_ project: String) {
    if status(project) == "start" { return }

    Git.pull()

    let log = writeCommand(project, command: "start")

    Git.add(path: projectPath(project))
    Git.commit(message: log)
    Git.push()
  }

  static func stop(_ project: String) {
    if status(project) == "stop" { return }

    Git.pull()

    let log = writeCommand(project, command: "stop")

    Git.add(path: projectPath(project))
    Git.commit(message: log)
    Git.push()
  }

  static func stopAll() {
    projects().forEach{ stop($0) }
  }

  private static func writeCommand(_ project: String, command: String) -> String {
    if (!FileManager.default.fileExists(atPath: projectPath(project))) {
        FileManager.default.createFile(atPath: projectPath(project), contents: nil)
    }
    
    let file = FileHandle(forWritingAtPath: projectPath(project))
    let log = "\(Int(NSDate().timeIntervalSince1970)) \(timezone()) \(command)\n"

    file?.seekToEndOfFile()
    file?.write(log.data(using: .utf8)!)
    file?.closeFile()

    return log
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
