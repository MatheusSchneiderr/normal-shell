import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  spacing: Theme.spaceSm

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool powered: adapter !== null && adapter.enabled
  readonly property var all: adapter ? adapter.devices.values : []
  readonly property var known: all.filter(d => d.paired).sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
  readonly property var found: all.filter(d => !d.paired && d.name !== "").sort((a, b) => a.name.localeCompare(b.name))

  Component.onDestruction: if (adapter && adapter.discovering) adapter.discovering = false

  component DeviceRow: Clickable {
    id: item
    required property var device
    property bool paired: true

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.rowHeight
    onActivated: {
      if (device.connected) device.disconnect()
      else if (paired) device.connect()
      else device.pair()
    }
    Keys.onDeletePressed: if (paired) device.forget()

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: Theme.spaceSm
      anchors.rightMargin: Theme.spaceSm
      spacing: Theme.spaceMd
      Glyph { text: Bt.glyph(device.icon); color: device.connected ? Theme.selected : Theme.iconBody }
      Label {
        Layout.fillWidth: true
        text: device.name
        elide: Text.ElideRight
        color: device.connected ? Theme.selected : Theme.textBody
      }
      Label {
        visible: device.connected && device.batteryAvailable
        text: Math.round(device.battery * 100) + "%"
        color: Theme.textHint
        font.pixelSize: Theme.fontSmall
      }
      Label {
        text: Bt.stateText(device)
        color: Theme.textHint
        font.pixelSize: Theme.fontSmall
      }
      Glyph {
        visible: item.paired && item.highlighted
        text: Icons.trash
        color: forgetArea.containsMouse ? Theme.danger : Theme.iconDim
        MouseArea { id: forgetArea; anchors.fill: parent; anchors.margins: -Theme.spaceSm; hoverEnabled: true; onClicked: device.forget() }
      }
    }
  }

  SectionHeader { text: "BLUETOOTH" }

  ListRow {
    glyph: Icons.bluetooth
    title: root.adapter ? (root.powered ? "Bluetooth on" : "Bluetooth off") : "No adapter"
    subtitle: "click to toggle"
    selected: root.powered
    onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
  }

  Repeater {
    model: root.powered ? root.known : []
    delegate: DeviceRow {
      required property var modelData
      device: modelData
    }
  }

  Label {
    visible: root.powered && root.known.length === 0
    text: "No paired devices"
    color: Theme.textHint
    Layout.leftMargin: Theme.spaceSm
  }

  SectionHeader { text: "AVAILABLE"; visible: root.adapter !== null && root.adapter.discovering && root.found.length > 0 }
  Repeater {
    model: root.adapter && root.adapter.discovering ? root.found : []
    delegate: DeviceRow {
      required property var modelData
      device: modelData
      paired: false
    }
  }

  ListRow {
    visible: root.powered
    glyph: Icons.search
    title: root.adapter && root.adapter.discovering ? "Scanning... (click to stop)" : "Scan for new devices"
    selected: root.adapter !== null && root.adapter.discovering
    onClicked: if (root.adapter) root.adapter.discovering = !root.adapter.discovering
  }
}
