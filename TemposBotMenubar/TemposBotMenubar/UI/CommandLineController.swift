//
//  CommandLineController.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 04/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class CommandLineController: NSViewController, NSTextFieldDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()
  }


  func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    switch commandSelector {
    case #selector(NSResponder.insertNewline(_:)):
      if Tempos.isValidCommand(command: textView.string) {
        textView.string = ""
      }
      else {
        textView.string = "Invalid command"
        textView.textColor = NSColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
      }
      return false

    default:
      return false
    }
  }
}
