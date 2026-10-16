import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ColumnLayout {
  id: root
  property string openDevice: ""

  Layout.fillWidth: true
  spacing: 0

  SectionHeader { text: "DEVICES"; Layout.bottomMargin: Theme.spaceSm }

  Repeater {
    model: Nm.devices
    delegate: ColumnLayout {
      id: entry
      required property var modelData
      readonly property var info: Nm.details[modelData.name] || ({})
      Layout.fillWidth: true
      spacing: 0

      ListRow {
        glyph: modelData.type === "wifi" ? Icons.wifi : modelData.type === "ethernet" ? Icons.ethernet : Icons.network
        title: modelData.name + "   " + Nm.typeLabel(modelData.type)
        subtitle: modelData.connection !== "" ? modelData.connection : modelData.state
        selected: modelData.state.indexOf("connected") === 0
        onClicked: root.openDevice = root.openDevice === modelData.name ? "" : modelData.name
      }

      Label {
        visible: root.openDevice === modelData.name
        Layout.leftMargin: Theme.spaceLg * 2
        Layout.topMargin: Theme.spaceXs
        Layout.bottomMargin: Theme.spaceSm
        color: Theme.muted
        lineHeight: 1.3
        text: "MAC       " + (info["GENERAL.HWADDR"] || "-")
          + "\nMTU       " + (info["GENERAL.MTU"] || "-")
          + "\nIPv4      " + (info["IP4.ADDRESS[1]"] || "-")
          + "\nGateway   " + (info["IP4.GATEWAY"] || "-")
          + "\nDNS       " + [info["IP4.DNS[1]"], info["IP4.DNS[2]"], info["IP6.DNS[1]"]].filter(x => x).join(", ")
          + "\nDomain    " + (info["IP4.DOMAIN[1]"] || "-")
          + "\nIPv6      " + (info["IP6.ADDRESS[1]"] || "-")
      }
    }
  }
}
