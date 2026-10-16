import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components

FloatingWindow {
  id: win
  title: "Settings"
  color: Theme.bg
  implicitWidth: Theme.settingsWidth
  implicitHeight: Theme.settingsHeight
  minimumSize: Qt.size(760, 480)

  property string page: "network"
  signal closeRequested()

  onVisibleChanged: if (!visible) closeRequested()

  readonly property var pages: [
    { id: "network", label: "Network", icon: Icons.wifi, file: "../modules/network/NetworkPage.qml" },
    { id: "sound", label: "Sound", icon: Icons.volumeHigh, file: "../modules/sound/SoundPage.qml" },
    { id: "bluetooth", label: "Bluetooth", icon: Icons.bluetooth, file: "../modules/bluetooth/BluetoothPage.qml" },
    { id: "apps", label: "Default apps", icon: Icons.apps, file: "../modules/default-apps/DefaultAppsPage.qml" },
    { id: "appearance", label: "Appearance", icon: Icons.image, file: "../modules/appearance/AppearancePage.qml" },
    { id: "datetime", label: "Date & time", icon: Icons.clock, file: "../modules/calendar/DateTimePage.qml" },
    { id: "printers", label: "Printers", icon: Icons.printer, file: "../modules/printers/PrintersPage.qml" }
  ]

  function select(id) {
    for (let i = 0; i < pages.length; i++) if (pages[i].id === id) { page = id; return }
  }

  function step(delta) {
    let index = 0
    for (let i = 0; i < pages.length; i++) if (pages[i].id === page) index = i
    page = pages[(index + delta + pages.length) % pages.length].id
  }

  Item {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: win.closeRequested()

    Rectangle {
      id: side
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: Theme.sidebarWidth
      color: Theme.surface

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spaceMd
        spacing: Theme.spaceXs

        Label {
          text: "Settings"
          color: Theme.bright
          font.pixelSize: Theme.fontLarge
          font.bold: true
          Layout.leftMargin: Theme.spaceSm
          Layout.bottomMargin: Theme.spaceMd
        }

        Repeater {
          model: win.pages
          delegate: ListRow {
            required property var modelData
            glyph: modelData.icon
            title: modelData.label
            selected: win.page === modelData.id
            Layout.preferredHeight: Theme.buttonHeight
            Keys.onDownPressed: win.step(1)
            Keys.onUpPressed: win.step(-1)
            onClicked: win.page = modelData.id
          }
        }

        Item { Layout.fillHeight: true }
      }
    }

    Loader {
      id: body
      anchors.left: side.right
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      source: {
        for (let i = 0; i < win.pages.length; i++) if (win.pages[i].id === win.page) return win.pages[i].file
        return ""
      }
    }
  }
}
