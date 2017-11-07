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
  let ROW_HEIGHT = 31
  let COLUMN_WIDTHS = [
    "project": CGFloat(180),
    "actions": CGFloat(60),
    "command": CGFloat(160),
    "report": CGFloat(160)
  ]
  let LOM_RED = NSColor(red: 0.75, green: 0.15, blue: 0.09, alpha: 1.0) // #BF2718, rgb(191,39,24)
  let LOM_RED_HL = NSColor(red: 0.92, green: 0.3, blue: 0.36, alpha: 1.0) // #EB4D5C, rgb(235,77,92)

  var refreshButton: NSButton?
  var tableView: NSTableView?
  var projects: Array<String>?

  override func loadView() {
    print("ProjectList loadView()")

    projects = Tempos.projects()

    view = NSView(frame: NSRect(x: 0, y: 0, width: TABLE_WIDTH + 46, height: ((ROW_HEIGHT + 2) * projects!.count)))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    print("ProjectsListController viewDidLoad")

    refreshButton = NSButton(title: "Start", target: self, action: #selector(self.handleStart))

    tableView = NSTableView(frame: NSRect(x: 18, y: 0, width: TABLE_WIDTH, height: ROW_HEIGHT * projects!.count))
    tableView!.allowsColumnResizing = false
    tableView!.columnAutoresizingStyle = .noColumnAutoresizing
    tableView!.rowHeight = CGFloat(ROW_HEIGHT)
    tableView!.isEnabled = false
    tableView!.rowSizeStyle = .custom

    tableView!.delegate = self
    tableView!.dataSource = self

    tableView!.headerView = nil

    let projectCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "project"))
    projectCol.minWidth = COLUMN_WIDTHS["project"]!

    let actionsCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "actions"))
    actionsCol.minWidth = COLUMN_WIDTHS["actions"]!
    actionsCol.maxWidth = COLUMN_WIDTHS["actions"]!

    // let commandCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "command"))
    // commandCol.minWidth = COLUMN_WIDTHS["command"]!

    let reportCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "report"))
    reportCol.minWidth = COLUMN_WIDTHS["report"]!

    tableView!.addTableColumn(projectCol)
    tableView!.addTableColumn(actionsCol)
    // tableView!.addTableColumn(commandCol)
    tableView!.addTableColumn(reportCol)

    self.view.addSubview(tableView!)
  }

  func refresh() {
    projects = Tempos.projects()
    view.frame = NSRect(x: 0, y: 0, width: TABLE_WIDTH + 46, height: ((ROW_HEIGHT + 2) * projects!.count))
    tableView!.reloadData()
  }

  @objc func handleStart(sender: NSButton) {
    Tempos.start(projects![sender.tag])
    tableView!.reloadData()
  }

  @objc func handleStop(sender: NSButton) {
    Tempos.stop(projects![sender.tag])
    tableView!.reloadData()
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
    return projects!.count
  }

  func selectionShouldChange(in tableView: NSTableView) -> Bool {
    return false
  }

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return CGFloat(ROW_HEIGHT)
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
        label.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        label.setFrameOrigin(NSPoint(
          x: 0,
          y: (cellView.bounds.height - label.bounds.height) / 2
        ))
        cellView.addSubview(label)

        break
      case "actions":
        let status = Tempos.status(projects![row])
        let button = ColoredButton(
          title: status == "start" ? "Stop" : "Start",
          target: self,
          action: status == "start" ? #selector(self.handleStop) : #selector(self.handleStart)
        )
        button.frame = NSRect(x: 2, y: 0, width: Int(COLUMN_WIDTHS["actions"]!) - 4, height: 22)
        if (status == "start") {
          button.backgroundColor = LOM_RED
          button.backgroundColorHover = LOM_RED_HL
        }
        button.tag = row

        button.bezelStyle = .inline
        button.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        button.setFrameOrigin(NSPoint(
          x: (cellView.bounds.width - button.bounds.width) / 2,
          y: (cellView.bounds.height - button.bounds.height) / 2 + 4
        ))

        cellView.addSubview(button)

        break
      // case "command":
      //   let command = NSTextField(frame: CGRect(x: 0, y: 0, width: Int(COLUMN_WIDTHS["command"]!) - 5, height: 28))
      //   command.wantsLayer = true

      //   command.delegate = self
      //   command.usesSingleLineMode = true
      //   command.isEditable = true
      //   command.isSelectable = true
      //   command.isEnabled = true
      //   command.backgroundColor = .white
      //   command.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
      //   command.setFrameOrigin(NSPoint(
      //     x: (cellView.bounds.width - command.bounds.width) / 2,
      //     y: (cellView.bounds.height - command.bounds.height) / 2
      //   ))

      //   cellView.addSubview(command)

      //   break
      case "report":
        cellView.frame = NSRect(x: 0, y: 0, width: Int(COLUMN_WIDTHS["report"]!), height: ROW_HEIGHT)

        let report = NSTextField(labelWithString: Tempos.report(projects![row]))
        report.autoresizingMask = [.minXMargin, .maxXMargin, .minYMargin, .maxYMargin]
        report.setFrameOrigin(NSPoint(
          x: 0,
          y: (cellView.bounds.height - report.bounds.height) / 2
        ))
        cellView.addSubview(report)
        break

      default:
        break
      }

      return cellView
    }
  }

}
