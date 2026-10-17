import QtQuick
import QtQuick.Layouts
import qs
import qs.components

SettingsPage {
  id: root
  title: "Network"

  property string editUuid: ""
  property string editName: ""
  property bool hiddenOpen: false

  function edit(profile) { editName = profile.name; editUuid = profile.uuid }

  Component.onCompleted: Nm.hold()
  Component.onDestruction: Nm.release()

  ColumnLayout {
    visible: root.editUuid === ""
    Layout.fillWidth: true
    spacing: Theme.spaceMd

    StatusMessage { text: Nm.message; ok: Nm.good }

    SectionHeader { text: "STATUS" }
    FormRow {
      label: "Networking"
      hint: "Master switch for all connections"
      Toggle { checked: Nm.networking; onToggled: v => Nm.setNetworking(v) }
    }
    FormRow {
      label: "Wi-Fi"
      Toggle { checked: Nm.wifiOn; onToggled: v => Nm.setWifi(v) }
    }
    FormRow {
      label: "Internet access"
      Label {
        text: Nm.connectivity === "full" ? "Connected" : Nm.connectivity === "limited" ? "Limited (captive portal?)" : Nm.connectivity === "portal" ? "Sign-in required" : Nm.connectivity === "none" ? "No internet" : Nm.connectivity
        color: Nm.connectivity === "full" ? Theme.success : Nm.connectivity === "none" ? Theme.danger : Theme.warning
      }
    }

    DeviceSection {}

    SectionHeader { text: "WI-FI NETWORKS"; visible: Nm.wifiOn }
    Label { visible: Nm.wifiOn && !Nm.scanned; text: "Scanning..."; color: Theme.textHint }
    WifiList { visible: Nm.wifiOn; showForget: true; showBand: true }
    RowLayout {
      visible: Nm.wifiOn
      spacing: Theme.spaceMd
      ActionButton { text: "Rescan"; onActivated: Nm.rescanNow() }
      ActionButton { text: root.hiddenOpen ? "Cancel" : "Connect to hidden network"; onActivated: root.hiddenOpen = !root.hiddenOpen }
    }
    RowLayout {
      visible: Nm.wifiOn && root.hiddenOpen
      spacing: Theme.spaceMd
      TextField { id: hiddenSsid; placeholder: "Network name (SSID)"; Layout.preferredWidth: Theme.fieldMd }
      TextField { id: hiddenPass; password: true; placeholder: "Password (optional)"; Layout.preferredWidth: Theme.fieldMd }
      ActionButton {
        text: "Connect"
        primary: true
        onActivated: { Nm.connectWifi(hiddenSsid.text, hiddenPass.text, true); root.hiddenOpen = false }
      }
    }

    SectionHeader { text: "SAVED CONNECTIONS" }
    Label { visible: Nm.savedProfiles.length === 0; text: "None"; color: Theme.textHint }
    Repeater {
      model: Nm.savedProfiles
      delegate: ListRow {
        required property var modelData
        glyph: modelData.type === "802-11-wireless" ? Icons.wifi : modelData.type === "802-3-ethernet" ? Icons.ethernet : modelData.type === "vpn" || modelData.type === "wireguard" ? Icons.lock : Icons.network
        title: modelData.name
        subtitle: Nm.typeLabel(modelData.type) + (modelData.active ? "  active" : "") + (modelData.auto ? "" : "  manual") + "   " + Icons.chevronRight
        selected: modelData.active
        onClicked: root.edit(modelData)
      }
    }

    VpnSection { onEdit: profile => root.edit(profile) }

    HotspotSection {}
  }

  ConnectionEditor {
    visible: root.editUuid !== ""
    Layout.fillWidth: true
    uuid: root.editUuid
    name: root.editName
    onBack: { root.editUuid = ""; Nm.refresh() }
    onChanged: Nm.refresh()
  }
}
