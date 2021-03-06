//
//  Git.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 03/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

// import Foundation
import Foundation

class Git {
  static func isValidRepo(path: String) -> Bool {
    let task = Process()
    task.launchPath = "/usr/bin/git"
    task.currentDirectoryPath = path
    task.arguments = ["status"]

    task.launch()
    task.waitUntilExit()

    return task.terminationStatus == 0
  }

  static func repoRoot(path: String) -> String {
    let task = Process()
    task.launchPath = "/usr/bin/git"
    task.currentDirectoryPath = path
    task.arguments = ["rev-parse", "--show-toplevel"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let handle = pipe.fileHandleForReading
    let data = handle.readDataToEndOfFile()

    task.waitUntilExit()

    let root = String(data: data, encoding: .utf8)!
    return root.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static func commiter() -> String {
    let task = prepareGitTask()
    task.arguments = ["config", "user.email"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let handle = pipe.fileHandleForReading
    let data = handle.readDataToEndOfFile()

    task.waitUntilExit()

    return String(data: data, encoding: .utf8)!
  }

  static func pull() {
    let task = prepareGitTask()
    task.arguments = ["pull"]

    task.launch()
    task.waitUntilExit()
  }

  static func push() {
    let task = prepareGitTask()
    task.arguments = ["push"]

    task.launch()
    task.waitUntilExit()
  }

  static func add(path: String) {
    let task = prepareGitTask()
    task.arguments = ["add", path]

    task.launch()
    task.waitUntilExit()
  }

  static func commit(message: String) {
    let task = prepareGitTask()
    task.arguments = ["commit", "-m", message]

    task.launch()
    task.waitUntilExit()
  }

  private static func prepareGitTask() -> Process {
    let task = Process()
    task.launchPath = "/usr/bin/git"
    task.currentDirectoryPath = UserDefaults.standard.string(forKey: "repo")!

    return task
  }

}
