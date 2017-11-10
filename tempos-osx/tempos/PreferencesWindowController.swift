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

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

  var delegate: PreferencesWindowDelegate?

  @IBOutlet weak var apiKeyTextField: TextField!
  @IBOutlet weak var optOnlyWorkingProjects: NSButton!
  
  override var windowNibName: NSNib.Name? {
    return NSNib.Name("PreferencesWindow")
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    window?.delegate = self

    if let defaultRepo = UserDefaults.standard.string(forKey: "repo") {
      apiKeyTextField.stringValue = defaultRepo
    }
    apiKeyTextField.isSelectable = true

    self.window?.title = "Preferences"
    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func windowWillClose(_ notification: Notification) {
    UserDefaults.standard.setValue(apiKeyTextField.stringValue, forKey: "repo")

    delegate?.preferencesDidUpdate()
  }

  @IBAction func openPathChooser(sender: AnyObject) {
    let dialog = NSOpenPanel()

    dialog.title = "Choose the path for your tempos repository"
    dialog.showsResizeIndicator = true
    dialog.showsHiddenFiles = false
    dialog.canChooseFiles = false
    dialog.canChooseDirectories = true
    dialog.allowsMultipleSelection = false

    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
      if let url = dialog.url {
        if !Git.isValidRepo(path: url.path) {
          showAlert(title: "Invalid git repository", message: "Please select a valid git repository")
        }
        else {
          apiKeyTextField.stringValue = Git.repoRoot(path: url.path)
        }
      }
    }
  }

  private func showAlert(title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Ok")

    alert.runModal()
  }
}
