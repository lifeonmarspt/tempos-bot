//
//  ColoredButton.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 05/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

class ColoredButton: NSButton {

  public var backgroundColor = NSColor(cgColor: CGColor(gray: 0.4, alpha: 1.0))
  public var backgroundColorHover = NSColor(cgColor: CGColor(gray: 0.5, alpha: 1.0))
  public var textColor = NSColor(cgColor: CGColor(gray: 1, alpha: 1.0))
  public var textColorHover = NSColor(cgColor: CGColor(gray: 1, alpha: 1.0))
  public var xRadius:CGFloat = 11
  public var yRadius:CGFloat = 11

  private var isHovered = false
  private var trackingArea: NSTrackingArea?

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
      // Drawing code here.

    let rect = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    let rectanglePath = NSBezierPath(roundedRect: rect, xRadius: xRadius, yRadius: yRadius)

    let fillColor = isHovered ? backgroundColorHover : backgroundColor

    // NSColor.clear.setFill()
    // rectanglePath.fill()
    // strokeColor!.setStroke()
    // rectanglePath.lineWidth = 5
    // rectanglePath.stroke()
    fillColor?.setFill()
    rectanglePath.fill()

    let textStyle = NSMutableParagraphStyle()
    textStyle.alignment = .center
    let fontAttrs = [
      NSAttributedStringKey.font: NSFont(name: "HelveticaNeue", size: NSFont.smallSystemFontSize)!,
      NSAttributedStringKey.foregroundColor: isHovered ? textColorHover : textColor,
      NSAttributedStringKey.paragraphStyle: textStyle
    ]

    let textHeight = self.title.boundingRect(
      with: NSSize(width: rect.width, height: CGFloat.infinity),
      options: .usesLineFragmentOrigin,
      attributes: fontAttrs
    ).height

    let textRect = NSRect(
      x: 0,
      y: ((rect.height - textHeight) / 2),
      width: rect.width,
      height: textHeight
    )

    NSGraphicsContext.saveGraphicsState()
    self.title.draw(in: textRect.offsetBy(dx: 0, dy: -1), withAttributes: fontAttrs)
    NSGraphicsContext.restoreGraphicsState()
  }

  override func viewDidMoveToSuperview() {
    let rect = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    trackingArea = NSTrackingArea(
      rect: rect,
      options: [.mouseEnteredAndExited, .activeAlways, .cursorUpdate, .inVisibleRect],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea(trackingArea!)
  }
  override func mouseEntered(with event: NSEvent) {
    isHovered = true
    needsDisplay = true
  }

  override func mouseExited(with event: NSEvent) {
    isHovered = false
    needsDisplay = true
  }
}
