//
//  PreferencesWindow.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 27/10/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
  func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
  
  var delegate: PreferencesWindowDelegate?
  
  @IBOutlet weak var apiKeyTextField: NSTextField!
  
  override var windowNibName: NSNib.Name? {
    return NSNib.Name("PreferencesWindow")
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    apiKeyTextField.stringValue = UserDefaults.standard.string(forKey: "apiKey")!
    apiKeyTextField.isSelectable = true
    
    self.window?.title = "Preferences"
    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  func windowWillClose(_ notification: Notification) {
    let defaults = UserDefaults.standard
    let apiKey = apiKeyTextField.stringValue
    
    if (!apiKey.isEmpty) {
      defaults.setValue(apiKeyTextField.stringValue, forKey: "apiKey")
    }
    
    delegate?.preferencesDidUpdate()
  }
}
