//
//  StatusMenuController.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 27/10/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {
  var statusItem: NSStatusItem!
  var preferencesWindow: PreferencesWindowController!
  var projectsListController: ProjectListController!

  @IBOutlet var statusMenu: NSMenu!
  @IBOutlet weak var currentUserItem: NSMenuItem!
  @IBOutlet weak var projectsListItem: NSMenuItem!

  @IBAction func refreshClicked(sender: NSMenuItem) {
    projectsListController.refresh()
  }

  @IBAction func preferencesClicked(sender: NSMenuItem) {
    preferencesWindow.showWindow(nil)
  }

  @IBAction func quitClicked(sender: NSMenuItem) {
    NSApplication.shared.terminate(self)
  }

  override func awakeFromNib() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.title = "⏱🤖"

    statusMenu.delegate = self
    statusItem.menu = statusMenu

    preferencesWindow = PreferencesWindowController()
    preferencesWindow.delegate = self

    projectsListController = ProjectListController()

    setupMenuItems()
  }

  private func setupMenuItems() {
    let defaults = UserDefaults.standard
    let defaultRepo = defaults.string(forKey: "repo")

    // default values
    currentUserItem.title = "Please set a valid repository in preferences"
    projectsListController.refresh()

    if let repo = defaultRepo {
      if (repo.isEmpty) { return }
    }
    else { return }

    currentUserItem.title = Git.commiter()
    projectsListItem.view = projectsListController.view
  }
}

extension MainMenuController: PreferencesWindowDelegate {
  func preferencesDidUpdate() {
    setupMenuItems()
  }
}

extension MainMenuController: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    projectsListController.refresh()
  }
}
