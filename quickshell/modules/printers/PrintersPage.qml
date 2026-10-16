import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

SettingsPage {
  id: root
  title: "Printers"

  property var printers: []
  property string defaultPrinter: ""
  property var jobs: []
  property var options: []
  property string selected: ""
  property var found: []
  property bool addOpen: false
  property bool scanning: false
  property string message: ""
  property bool good: false

  readonly property string testText: "Printer test page"

  function load() {
    if (!listCmd.busy) listCmd.run()
    if (!defCmd.busy) defCmd.run()
    if (!uriCmd.busy) uriCmd.run()
    if (!jobCmd.busy) jobCmd.run()
  }

  function loadOptions() {
    options = []
    if (selected !== "") optCmd.run(["lpoptions", "-p", selected, "-l"])
  }

  function act(args, note) {
    if (!action.run(args)) return
    action.note = note || ""
  }

  Cmd {
    id: listCmd
    command: ["lpstat", "-p"]
    onFinished: (code, out) => {
      root.printers = out.split("\n").map(l => /^printer (\S+) (.*)$/.exec(l)).filter(m => m).map(m => ({ name: m[1], state: /disabled/.test(m[2]) ? "disabled" : /printing/.test(m[2]) ? "printing" : "idle", uri: "" }))
    }
  }
  Cmd { id: defCmd; command: ["lpstat", "-d"]; onFinished: (code, out) => { const m = /: (\S+)\s*$/.exec(out.trim()); root.defaultPrinter = m ? m[1] : "" } }
  Cmd {
    id: uriCmd
    command: ["lpstat", "-v"]
    onFinished: (code, out) => {
      const map = {}
      for (const l of out.split("\n")) { const m = /^device for (\S+): (.*)$/.exec(l); if (m) map[m[1]] = m[2] }
      root.printers = root.printers.map(p => ({ name: p.name, state: p.state, uri: map[p.name] || "" }))
    }
  }
  Cmd {
    id: jobCmd
    command: ["lpstat", "-o"]
    onFinished: (code, out) => {
      root.jobs = out.split("\n").map(l => /^(\S+)-(\d+)\s+(\S+)\s+(\d+)\s+(.*)$/.exec(l)).filter(m => m).map(m => ({ id: m[2], printer: m[1], owner: m[3], size: parseInt(m[4]), when: m[5] }))
    }
  }
  Cmd {
    id: optCmd
    onFinished: (code, out) => {
      const rows = []
      for (const l of out.split("\n")) {
        const m = /^(\w+)\/([^:]+):\s*(.*)$/.exec(l)
        if (!m) continue
        const choices = m[3].split(/\s+/).filter(c => c)
        if (choices.length < 2 || choices.length > 14) continue
        const current = (choices.find(c => c.startsWith("*")) || "").slice(1)
        rows.push({ key: m[1], label: m[2], value: current, choices: choices.map(c => c.replace(/^\*/, "")).map(c => ({ label: c, value: c })) })
      }
      root.options = rows
    }
  }
  Cmd {
    id: action
    property string note: ""
    onFinished: (code, out, err) => {
      root.good = code === 0
      const lines = err.split("\n").filter(l => l.length > 0 && l.indexOf("deprecated") < 0)
      root.message = code === 0 ? note : (lines[0] || "Failed")
      root.load()
    }
  }
  Cmd {
    id: discover
    command: ["lpinfo", "-v"]
    onFinished: (code, out) => {
      root.scanning = false
      root.found = out.split("\n").map(l => /^(\S+)\s+(\S+:\/\/\S*)$/.exec(l)).filter(m => m).map(m => ({ kind: m[1], uri: m[2] }))
        .filter(d => d.uri.indexOf("beh:") !== 0 && d.uri.indexOf("//") >= 0)
    }
  }

  Component.onCompleted: load()
  Timer { interval: 5000; running: root.visible; repeat: true; onTriggered: root.load() }
  onSelectedChanged: loadOptions()

  StatusMessage { text: root.message; ok: root.good }

  SectionHeader { text: "PRINTERS" }
  Label { visible: root.printers.length === 0; text: "No printers configured"; color: Theme.muted }

  Repeater {
    model: root.printers
    delegate: ColumnLayout {
      id: entry
      required property var modelData
      readonly property bool open: root.selected === modelData.name
      Layout.fillWidth: true
      spacing: 0

      ListRow {
        glyph: Icons.printer
        title: modelData.name + (modelData.name === root.defaultPrinter ? "   default" : "")
        subtitle: modelData.state + "   ›"
        selected: modelData.state !== "disabled"
        onClicked: { root.selected = entry.open ? "" : modelData.name }
      }

      ColumnLayout {
        visible: entry.open
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceLg * 2
        Layout.topMargin: Theme.spaceSm
        Layout.bottomMargin: Theme.spaceMd
        spacing: Theme.spaceSm

        Label { text: modelData.uri; color: Theme.muted; font.pixelSize: Theme.fontSmall; elide: Text.ElideMiddle; Layout.fillWidth: true }

        RowLayout {
          spacing: Theme.spaceMd
          ActionButton {
            text: "Make default"
            enabled: modelData.name !== root.defaultPrinter
            onActivated: root.act(["lpadmin", "-d", modelData.name], "Default printer set")
          }
          ActionButton {
            text: "Print test page"
            onActivated: root.act(["sh", "-c", "printf '%s\\n%s\\n' \"$2\" \"$(date)\" | lp -d \"$1\"", "sh", modelData.name, root.testText], "Test page sent")
          }
          ActionButton {
            text: modelData.state === "disabled" ? "Enable" : "Pause"
            onActivated: root.act([modelData.state === "disabled" ? "cupsenable" : "cupsdisable", modelData.name], "")
          }
          ConfirmButton {
            label: "Remove"
            question: "Really remove?"
            onConfirmed: { root.selected = ""; root.act(["lpadmin", "-x", modelData.name], "Printer removed") }
          }
        }

        Repeater {
          model: root.options
          delegate: FormRow {
            required property var modelData
            label: modelData.label
            Dropdown {
              Layout.fillWidth: true
              value: modelData.value
              options: modelData.choices
              onPicked: v => { root.act(["lpoptions", "-p", entry.modelData.name, "-o", modelData.key + "=" + v], ""); optCmd.run(["lpoptions", "-p", entry.modelData.name, "-l"]) }
            }
          }
        }
      }
    }
  }

  SectionHeader { text: "PRINT QUEUE" }
  Label { visible: root.jobs.length === 0; text: "No pending jobs"; color: Theme.muted }
  Repeater {
    model: root.jobs
    delegate: RowLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: Theme.spaceMd
      Label { text: modelData.printer + " #" + modelData.id; Layout.preferredWidth: Theme.fieldSm; elide: Text.ElideRight }
      Label { text: modelData.owner + "   " + Math.round(modelData.size / 1024) + " KB   " + modelData.when; color: Theme.muted; Layout.fillWidth: true; elide: Text.ElideRight }
      ActionButton { text: "Cancel"; onActivated: root.act(["cancel", modelData.printer + "-" + modelData.id], "Job cancelled") }
    }
  }

  SectionHeader { text: "ADD A PRINTER" }
  RowLayout {
    spacing: Theme.spaceMd
    ActionButton { text: root.addOpen ? "Close" : "Add printer..."; primary: !root.addOpen; onActivated: root.addOpen = !root.addOpen }
  }
  ColumnLayout {
    visible: root.addOpen
    Layout.fillWidth: true
    spacing: Theme.spaceMd

    FormRow {
      label: "Name"
      hint: "Letters, numbers and underscores"
      TextField { id: printerName; Layout.preferredWidth: Theme.fieldLg; placeholder: "Office_printer" }
    }
    FormRow {
      label: "Address"
      hint: "ipp://192.168.1.50/ipp/print, socket://host:9100, usb://..."
      TextField { id: printerUri; Layout.fillWidth: true; placeholder: "ipp://printer.local/ipp/print" }
    }
    RowLayout {
      spacing: Theme.spaceMd
      ActionButton {
        text: "Add"
        primary: true
        enabled: printerName.text !== "" && printerUri.text !== ""
        onActivated: {
          root.act(["lpadmin", "-p", printerName.text.replace(/[^A-Za-z0-9_-]/g, "_"), "-E", "-v", printerUri.text, "-m", "everywhere"], "Printer added")
          root.addOpen = false
        }
      }
      ActionButton {
        text: root.scanning ? "Searching..." : "Search for printers"
        onActivated: { if (!root.scanning) { root.scanning = true; discover.run() } }
      }
    }
    Label { visible: !root.scanning && root.found.length === 0 && discover.output !== ""; text: "No printers found. Use the address field for a network printer."; color: Theme.muted }
    Repeater {
      model: root.found
      delegate: ListRow {
        required property var modelData
        glyph: modelData.kind === "direct" ? Icons.usb : Icons.wifi
        title: modelData.uri
        subtitle: modelData.kind
        onClicked: printerUri.text = modelData.uri
      }
    }
  }
}
