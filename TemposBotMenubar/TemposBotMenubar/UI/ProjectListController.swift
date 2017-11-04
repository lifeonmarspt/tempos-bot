//
//  ProjectListController.swift
//  TemposBotMenubar
//
//  Created by João Gradim on 04/11/2017.
//  Copyright © 2017 Life on Mars. All rights reserved.
//

import Cocoa

// https://stackoverflow.com/questions/34124228/initialize-a-subclass-of-nsviewcontroller-without-a-xib-file
class ProjectListController: NSViewController {

  let TABLE_WIDTH = 400
  let ROW_HEIGHT = 30
  let COLUMN_WIDTHS = [
    "project": CGFloat(180),
    "actions": CGFloat(60),
    "command": CGFloat(160),
  ]

  var tableView: NSTableView?
  var projects: Array<String>?

  override func loadView() {
    print("ProjectList loadView()")

    projects = Tempos.projects()

    view = NSView(frame: NSRect(x: 0, y: 0, width: TABLE_WIDTH + 46, height: (ROW_HEIGHT * projects!.count) + 4))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    print("ProjectsListController viewDidLoad")

    tableView = NSTableView(frame: NSRect(x: 18, y: 0, width: TABLE_WIDTH, height: ROW_HEIGHT * projects!.count))
    tableView!.allowsColumnResizing = false
    tableView!.columnAutoresizingStyle = .noColumnAutoresizing
    tableView!.rowHeight = CGFloat(ROW_HEIGHT)
    tableView!.isEnabled = false

    tableView!.delegate = self
    tableView!.dataSource = self

    tableView!.headerView = nil

    let projectCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "project"))
    projectCol.minWidth = COLUMN_WIDTHS["project"]!

    let startStopCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "actions"))
    startStopCol.minWidth = COLUMN_WIDTHS["actions"]!
    startStopCol.maxWidth = COLUMN_WIDTHS["actions"]!

    let actionsCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "command"))
    actionsCol.minWidth = COLUMN_WIDTHS["command"]!

    tableView!.addTableColumn(projectCol)
    tableView!.addTableColumn(startStopCol)
    tableView!.addTableColumn(actionsCol)

    self.view.addSubview(tableView!)
  }

  @objc func handleStart() {
    print("handleStart")
  }

  @objc func handleStop() {
    print("handleStop")
  }
}

//------------------------------------------------------------------------------
// NSTextFieldDelegate
//------------------------------------------------------------------------------
extension ProjectListController: NSTextFieldDelegate {

  func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    switch commandSelector {
    case #selector(NSResponder.insertNewline(_:)):
      if Tempos.isValidCommand(command: textView.string) {
        textView.string = ""
      }
      else {
        textView.string = "Invalid command"
      }
      return false

    default:
      return false
    }
  }

}

//------------------------------------------------------------------------------
// NSTableViewDelegate, NSTableViewDataSource
//------------------------------------------------------------------------------
extension ProjectListController: NSTableViewDelegate, NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    print("rows: \(projects!.count)")
    return projects!.count
  }

  func selectionShouldChange(in tableView: NSTableView) -> Bool {
    return false
  }

  override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
    print("validateProposedFirstResponder \(responder)")

    return true
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    if let spareView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProjectView"), owner: self) {
      return spareView
    }
    else {
      let cellView = NSView()
      cellView.wantsLayer = true

      switch tableColumn!.identifier.rawValue {
      case "project":
        cellView.frame = NSRect(x: 0, y: 0, width: Int(COLUMN_WIDTHS["project"]!), height: ROW_HEIGHT)

        let label = NSTextField(labelWithString: projects![row])
        label.isEditable = false
        label.isSelectable = false
        label.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        label.setFrameOrigin(NSPoint(
          x: 0,
          y: (cellView.bounds.height - label.bounds.height) / 2
        ))
        cellView.addSubview(label)

        break
      case "actions":
        let button = NSButton(title: "Start", target: self, action: #selector(self.handleStart))

        button.frame = NSRect(x: 0, y: 0, width: Int(COLUMN_WIDTHS["actions"]!) - 10, height: 20)
        button.bezelStyle = .inline

        button.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        button.setFrameOrigin(NSPoint(
          x: (cellView.bounds.width - button.bounds.width) / 2,
          y: (cellView.bounds.height - button.bounds.height) / 2 + 4
        ))

        cellView.addSubview(button)

        break
      case "command":
        let command = NSTextField(frame: CGRect(x: 0, y: 0, width: Int(COLUMN_WIDTHS["command"]!) - 5, height: 20))
        command.wantsLayer = true

        command.delegate = self
        command.usesSingleLineMode = true
        command.isEditable = true
        command.isSelectable = true
        command.isEnabled = true
        command.backgroundColor = .white
        command.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        command.setFrameOrigin(NSPoint(
          x: (cellView.bounds.width - command.bounds.width) / 2,
          y: (cellView.bounds.height - command.bounds.height) / 2
        ))

        cellView.addSubview(command)

        break

      default:
        break
      }

      return cellView
    }
  }

}
