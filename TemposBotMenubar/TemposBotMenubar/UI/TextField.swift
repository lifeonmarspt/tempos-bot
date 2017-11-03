//
//  TextField.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 03/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class TextField: NSTextField {
  
  private let commandKey = NSEvent.ModifierFlags.command.rawValue
  private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }
  
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    if event.type == NSEvent.EventType.keyDown {
      if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
        switch event.charactersIgnoringModifiers! {
        case "x":
          if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
        case "c":
          if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
        case "v":
          if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
        case "z":
          if NSApp.sendAction(Selector(("undo:")), to:nil, from:self) { return true }
        case "a":
          if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
        default:
          break
        }
      }
    }
    
    return super.performKeyEquivalent(with: event)
  }
}
