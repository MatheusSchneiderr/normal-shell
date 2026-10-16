import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  spacing: Theme.spaceSm

  Component.onCompleted: Nm.hold()
  Component.onDestruction: Nm.release()

  SectionHeader { text: "NETWORK" }

  ListRow {
    glyph: Icons.wifi
    title: Nm.wifiOn ? "Wi-Fi on" : "Wi-Fi off"
    subtitle: Nm.wifiOn ? "click to turn off" : "click to turn on"
    selected: Nm.wifiOn
    onClicked: Nm.setWifi(!Nm.wifiOn)
  }

  Label {
    visible: Nm.current !== undefined
    Layout.leftMargin: Theme.spaceSm
    Layout.fillWidth: true
    text: Nm.current ? "Connected to " + Nm.current.ssid + (Nm.ip !== "" ? "   " + Nm.ip : "") : ""
    elide: Text.ElideRight
  }

  StatusMessage { text: Nm.message; font.pixelSize: Theme.fontSmall }

  Label { visible: Nm.wifiOn && !Nm.scanned; Layout.leftMargin: Theme.spaceSm; text: "Scanning..."; color: Theme.muted }

  WifiList { visible: Nm.wifiOn; maxHeight: Theme.popupListHeight }

  SectionHeader { text: "VPN"; visible: Nm.vpnProfiles.length > 0 }
  Repeater {
    model: Nm.vpnProfiles
    delegate: ListRow {
      required property var modelData
      glyph: Icons.lock
      title: modelData.name
      subtitle: modelData.active ? "connected" : ""
      selected: modelData.active
      onClicked: Nm.toggleProfile(modelData)
    }
  }

  ListRow {
    glyph: Icons.gear
    title: "Network settings..."
    onClicked: Ui.openSettings("network")
  }
}
