import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  signal edit(var profile)

  Layout.fillWidth: true
  spacing: Theme.spaceMd

  SectionHeader { text: "VPN" }

  Repeater {
    model: Nm.vpnProfiles
    delegate: RowLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: Theme.spaceXs
      ListRow {
        glyph: Icons.lock
        title: modelData.name
        subtitle: modelData.active ? "connected" : Nm.typeLabel(modelData.type)
        selected: modelData.active
        onClicked: Nm.toggleProfile(modelData)
      }
      ActionButton { text: "Edit"; onActivated: root.edit(modelData) }
    }
  }

  FormRow {
    label: "Import VPN profile"
    hint: "Path to an .ovpn or WireGuard .conf file"
    TextField { id: importPath; Layout.preferredWidth: Theme.fieldLg; placeholder: "~/vpn/work.ovpn" }
    Dropdown {
      id: importType
      Layout.preferredWidth: Theme.fieldSm
      value: "openvpn"
      options: [{ label: "OpenVPN", value: "openvpn" }, { label: "WireGuard", value: "wireguard" }]
      onPicked: v => value = v
    }
    ActionButton {
      text: "Import"
      onActivated: Nm.run(["sh", "-c", "nmcli connection import type \"$1\" file \"${2/#\\~/$HOME}\"", "sh", importType.value, importPath.text])
    }
  }
}
