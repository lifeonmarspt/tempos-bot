//
//  StatusMenuController.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 27/10/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {
  private var statusItem: NSStatusItem!
  private var preferencesWindow: PreferencesWindowController!
  private var projectsListController: ProjectListController!
  
  private var isActive: Bool = false

  @IBOutlet var statusMenu: NSMenu!
  @IBOutlet weak var currentUserItem: NSMenuItem!
  @IBOutlet weak var projectsListItem: NSMenuItem!
  @IBOutlet weak var newProjectSeparator: NSMenuItem!
  @IBOutlet weak var newProjectItem: NSMenuItem!

  @IBAction func newProjectClicked(sender: NSMenuItem) {
    let form = NSAlert()
    form.messageText = "Add new project"
    form.addButton(withTitle: "Add Project")
    form.addButton(withTitle: "Cancel")

    let projectInput = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
    projectInput.placeholderString = "client/project"

    form.accessoryView = projectInput
    form.window.initialFirstResponder = projectInput

    let response = form.runModal()

    if response == .alertFirstButtonReturn {
      let projectCreated = Tempos.createProject(path: projectInput.stringValue)
      print("projectCreated: \(projectCreated)")
    }
  }

  @IBAction func refreshClicked(sender: NSMenuItem) {
    projectsListController.refresh()
  }

  @IBAction func preferencesClicked(sender: NSMenuItem) {
    preferencesWindow.showWindow(nil)
  }

  @IBAction func quitClicked(sender: NSMenuItem) {
    if (Tempos.globalStatus() == "stop") {
      NSApplication.shared.terminate(self)
      return
    }
    
    let alert = NSAlert()
    alert.messageText = "Running timers"
    alert.informativeText = "You still have running timers. Do you wish to stop them before quitting?"
    alert.addButton(withTitle: "Stop timers and quit")
    alert.addButton(withTitle: "Quit anyway")
    alert.addButton(withTitle: "Cancel")
    
    let response = alert.runModal()
    if response == .alertThirdButtonReturn { return }
    if response == .alertFirstButtonReturn { Tempos.stopAll() }
    
    NSApplication.shared.terminate("self")
  }

  override func awakeFromNib() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    statusMenu.delegate = self
    statusItem.menu = statusMenu

    preferencesWindow = PreferencesWindowController()
    preferencesWindow.delegate = self

    projectsListController = ProjectListController()
    projectsListController.mainMenu = self

    setupMenuItems()

    setActive(Tempos.globalStatus() == "start")
  }

  func setActive(_ active: Bool) {
    self.isActive = active
    let icon = active ? "menubar-active" : "menubar-inactive"
    statusItem.image = NSImage(named: NSImage.Name(icon))
  }

  private func setupMenuItems() {
    let defaults = UserDefaults.standard
    let defaultRepo = defaults.string(forKey: "repo")

    // default values
    currentUserItem.title = "Please set a valid repository in preferences"
    newProjectSeparator.isHidden = true
    newProjectItem.isHidden = true
    projectsListController.refresh()

    if let repo = defaultRepo {
      if (repo.isEmpty) { return }
    }
    else { return }

    currentUserItem.title = Git.commiter()
    projectsListItem.view = projectsListController.view

    newProjectSeparator.isHidden = false
    newProjectItem.isHidden = false
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
