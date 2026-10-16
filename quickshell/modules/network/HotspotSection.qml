import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ColumnLayout {
  Layout.fillWidth: true
  spacing: Theme.spaceMd
  visible: Nm.wifiDevice !== ""

  SectionHeader { text: "HOTSPOT" }

  FormRow {
    label: "Share this connection"
    hint: "Uses the Wi-Fi adapter, so it disconnects you from the current Wi-Fi network"
    TextField { id: ssid; placeholder: "Network name"; Layout.preferredWidth: Theme.fieldMd }
    TextField { id: pass; password: true; placeholder: "Password (8+ characters)"; Layout.preferredWidth: Theme.fieldMd }
    Dropdown {
      id: band
      Layout.preferredWidth: Theme.fieldSm
      value: "bg"
      options: [{ label: "2.4 GHz", value: "bg" }, { label: "5 GHz", value: "a" }]
      onPicked: v => value = v
    }
  }

  RowLayout {
    spacing: Theme.spaceMd
    ActionButton {
      text: "Start hotspot"
      primary: true
      enabled: ssid.text !== "" && pass.text.length >= 8
      onActivated: Nm.run(["nmcli", "device", "wifi", "hotspot", "ifname", Nm.wifiDevice, "ssid", ssid.text, "password", pass.text, "band", band.value])
    }
    ActionButton { text: "Stop hotspot"; onActivated: Nm.run(["nmcli", "connection", "down", "id", "Hotspot"]) }
  }
}
