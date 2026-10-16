import QtQuick
import QtQuick.Layouts
import qs
import qs.components

ListView {
  id: list
  property int maxHeight: 0
  property bool showForget: false
  property bool showBand: false
  property string pendingSsid: ""

  Layout.fillWidth: true
  Layout.preferredHeight: maxHeight > 0 ? Math.min(contentHeight, maxHeight) : contentHeight
  interactive: maxHeight > 0
  clip: true
  model: Nm.networks

  Connections {
    target: Nm
    function onUsersChanged() { list.pendingSsid = "" }
  }

  delegate: ColumnLayout {
    id: entry
    required property var modelData
    width: list.width
    spacing: 0

    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spaceXs

      ListRow {
        glyph: modelData.secure ? Icons.lock : Icons.unlock
        title: modelData.ssid
        subtitle: (modelData.active ? "connected  " : modelData.saved ? "saved  " : "") + (list.showBand ? modelData.band + "  " : "") + Nm.bars(modelData.signal)
        selected: modelData.active
        onClicked: {
          if (!modelData.active && !modelData.saved && modelData.secure) {
            list.pendingSsid = list.pendingSsid === modelData.ssid ? "" : modelData.ssid
            password.text = ""
          } else Nm.toggleNetwork(modelData, "")
        }
      }

      ActionButton {
        visible: list.showForget && modelData.saved
        text: "Forget"
        onActivated: Nm.forget(modelData.ssid)
      }
    }

    RowLayout {
      visible: list.pendingSsid === modelData.ssid
      onVisibleChanged: if (visible) password.input.forceActiveFocus()
      Layout.fillWidth: true
      Layout.leftMargin: Theme.spaceLg
      spacing: Theme.spaceMd

      TextField {
        id: password
        Layout.fillWidth: true
        password: true
        placeholder: "Password for " + modelData.ssid
        onAccepted: { Nm.connectWifi(modelData.ssid, text, false); list.pendingSsid = "" }
      }
      ActionButton {
        text: "Connect"
        primary: true
        busy: Nm.busy
        onActivated: { Nm.connectWifi(modelData.ssid, password.text, false); list.pendingSsid = "" }
      }
    }
  }
}
