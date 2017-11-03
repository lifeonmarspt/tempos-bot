//
//  StatusMenuController.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 27/10/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject, PreferencesWindowDelegate {
  var statusItem: NSStatusItem!
  var preferencesWindow: PreferencesWindowController!
  
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var currentUser: NSMenuItem!
  
  @IBAction func preferencesClicked(sender: NSMenuItem) {
    preferencesWindow.showWindow(nil)
  }
  
  @IBAction func quitClicked(sender: NSMenuItem) {
    NSApplication.shared.terminate(self)
  }
  
  override func awakeFromNib() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.title = "⏱🤖"
    statusItem.menu = statusMenu
    
    preferencesWindow = PreferencesWindowController()
    preferencesWindow.delegate = self
    
    setupMenuItems()
  }
  
  func preferencesDidUpdate() {
    setupMenuItems()
  }
  
  private func setupMenuItems() {
    let defaults = UserDefaults.standard
    let defaultRepo = defaults.string(forKey: "repo")
    
    // default values
    currentUser.title = "Please set a valid repository in preferences"
    
    if let repo = defaultRepo {
      if (repo.isEmpty) { return }
    }
    else { return }
    
    currentUser.title = Git.commiter()
  }
}
