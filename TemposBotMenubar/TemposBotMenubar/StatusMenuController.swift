//
//  StatusMenuController.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 27/10/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
  var statusItem: NSStatusItem!
  var preferencesWindow: PreferencesWindow!
  
  @IBOutlet weak var statusMenu: NSMenu!
  
  // let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  override func awakeFromNib() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.title = "⏱🤖"
    statusItem.menu = statusMenu
    
    preferencesWindow = PreferencesWindow()
    preferencesWindow.delegate = self
  }
  
  func preferencesDidUpdate() {
    let defaults = UserDefaults.standard
    let apiKey = defaults.string(forKey: "apiKey") ?? "NO API KEY SET"
    
    NSLog("apiKey: %@", apiKey)
  }
  
  @IBAction func preferencesClicked(sender: NSMenuItem) {
    preferencesWindow.showWindow(nil)
  }
  
  @IBAction func quitClicked(sender: NSMenuItem) {
    NSApplication.shared.terminate(self)
  }
}
