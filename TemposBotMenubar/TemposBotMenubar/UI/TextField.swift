//
//  TextField.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 03/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class TextField: NSTextField {
  
  private let commandKey = NSEvent.ModifierFlags.CommandKeyMask.rawValue
  private let commandShiftKey = NSEvent.ModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
  
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    if event.type = NSEvent.
  }
}
