import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

SettingsPage {
  id: root
  title: "Bluetooth"

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool powered: adapter !== null && adapter.enabled
  readonly property var all: adapter ? adapter.devices.values : []
  readonly property var known: all.filter(d => d.paired).sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
  readonly property var found: all.filter(d => !d.paired && d.name !== "").sort((a, b) => a.name.localeCompare(b.name))
  property string openAddress: ""

  readonly property var timeouts: [
    { label: "Never", value: 0 }, { label: "1 minute", value: 60 }, { label: "3 minutes", value: 180 },
    { label: "5 minutes", value: 300 }, { label: "10 minutes", value: 600 }
  ]

  Component.onDestruction: if (adapter && adapter.discovering) adapter.discovering = false

  Cmd { id: alias }

  SectionHeader { text: "ADAPTER" }
  Label { visible: root.adapter === null; text: "No Bluetooth adapter found"; color: Theme.textHint }

  FormRow {
    visible: root.adapter !== null
    label: "Bluetooth"
    Toggle { checked: root.powered; onToggled: v => root.adapter.enabled = v }
  }
  FormRow {
    visible: root.powered
    label: "Name"
    hint: "How other devices see this computer"
    TextField {
      id: adapterName
      Layout.preferredWidth: Theme.fieldLg
      text: root.adapter ? root.adapter.name : ""
      onAccepted: alias.run(["bluetoothctl", "system-alias", text])
    }
    ActionButton { text: "Rename"; onActivated: alias.run(["bluetoothctl", "system-alias", adapterName.text]) }
  }
  FormRow {
    visible: root.powered
    label: "Discoverable"
    hint: "Let other devices find this computer"
    Toggle { checked: root.adapter.discoverable; onToggled: v => root.adapter.discoverable = v }
    Dropdown {
      Layout.preferredWidth: Theme.fieldSm
      value: root.adapter.discoverableTimeout
      options: root.timeouts
      onPicked: v => root.adapter.discoverableTimeout = v
    }
  }
  FormRow {
    visible: root.powered
    label: "Pairable"
    hint: "Accept pairing requests"
    Toggle { checked: root.adapter.pairable; onToggled: v => root.adapter.pairable = v }
    Dropdown {
      Layout.preferredWidth: Theme.fieldSm
      value: root.adapter.pairableTimeout
      options: root.timeouts
      onPicked: v => root.adapter.pairableTimeout = v
    }
  }

  SectionHeader { text: "MY DEVICES"; visible: root.powered }
  Label { visible: root.powered && root.known.length === 0; text: "No paired devices"; color: Theme.textHint }

  Repeater {
    model: root.powered ? root.known : []
    delegate: ColumnLayout {
      id: entry
      required property var modelData
      readonly property bool open: root.openAddress === modelData.address
      Layout.fillWidth: true
      spacing: 0

      RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceXs
        ListRow {
          glyph: Bt.glyph(modelData.icon)
          title: modelData.name
          subtitle: (modelData.connected && modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%  " : "") + Bt.stateText(modelData) + "   ›"
          selected: modelData.connected
          onClicked: { root.openAddress = entry.open ? "" : modelData.address }
        }
        ActionButton {
          text: modelData.connected ? "Disconnect" : "Connect"
          primary: !modelData.connected
          onActivated: modelData.connected ? modelData.disconnect() : modelData.connect()
        }
      }

      ColumnLayout {
        visible: entry.open
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceLg * 2
        Layout.topMargin: Theme.spaceSm
        Layout.bottomMargin: Theme.spaceMd
        spacing: Theme.spaceSm

        Label {
          color: Theme.textHint
          lineHeight: 1.3
          text: "Address    " + modelData.address + "\nType       " + Bt.kind(modelData.icon)
            + (modelData.deviceName !== modelData.name ? "\nOriginal   " + modelData.deviceName : "")
            + (modelData.batteryAvailable ? "\nBattery    " + Math.round(modelData.battery * 100) + "%" : "")
        }
        FormRow {
          label: "Name"
          TextField { id: deviceName; Layout.preferredWidth: Theme.fieldLg; text: modelData.name; onAccepted: modelData.name = text }
          ActionButton { text: "Rename"; onActivated: modelData.name = deviceName.text }
        }
        FormRow {
          label: "Trusted"
          hint: "Connect automatically without asking"
          Toggle { checked: modelData.trusted; onToggled: v => modelData.trusted = v }
        }
        FormRow {
          label: "Blocked"
          hint: "Refuse all connections from this device"
          Toggle { checked: modelData.blocked; onToggled: v => modelData.blocked = v }
        }
        RowLayout {
          spacing: Theme.spaceMd
          ConfirmButton {
            label: "Forget device"
            question: "Really forget?"
            onConfirmed: { root.openAddress = ""; modelData.forget() }
          }
        }
      }
    }
  }

  SectionHeader { text: "NEW DEVICES"; visible: root.powered }
  RowLayout {
    visible: root.powered
    spacing: Theme.spaceMd
    ActionButton {
      text: root.adapter && root.adapter.discovering ? "Stop scanning" : "Scan for devices"
      primary: !(root.adapter && root.adapter.discovering)
      onActivated: root.adapter.discovering = !root.adapter.discovering
    }
    Label { visible: root.adapter && root.adapter.discovering; text: "Searching..."; color: Theme.textHint }
  }
  Repeater {
    model: root.powered ? root.found : []
    delegate: RowLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: Theme.spaceXs
      ListRow {
        glyph: Bt.glyph(modelData.icon)
        title: modelData.name
        subtitle: modelData.pairing ? "pairing..." : Bt.kind(modelData.icon)
        onClicked: modelData.pair()
      }
      ActionButton { text: modelData.pairing ? "..." : "Pair"; primary: true; onActivated: modelData.pair() }
    }
  }
}
