import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs
import qs.components
import qs.services
import qs.modules.clipboard
import qs.modules.sound
import qs.modules.bluetooth
import qs.modules.network
import qs.modules.battery
import qs.modules.notifications
import qs.modules.calendar
import qs.modules.workspaces

PanelWindow {
  id: panel
  required property var modelData
  screen: modelData
  anchors { left: true; right: true; bottom: true }
  implicitHeight: Theme.barHeight
  exclusionMode: ExclusionMode.Normal
  WlrLayershell.layer: WlrLayer.Bottom
  exclusiveZone: Theme.barHeight
  color: Theme.fillWindow

  IdleInhibitor { window: panel; enabled: Battery.keepAwake }

  RowLayout {
    anchors.fill: parent
    anchors.topMargin: 0
    spacing: 2

    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: Theme.startButtonWidth
      Glyph {
        centered: true
        text: Icons.nix
        color: (startArea.containsMouse || Ui.menuOpen) ? Theme.selected : Theme.iconBody
        font.pixelSize: Theme.iconLarge
      }
      MouseArea {
        id: startArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Ui.toggleMenu()
      }
    }

    Pager {
      Layout.fillHeight: true
      Layout.preferredWidth: implicitWidth
    }

    Repeater {
      model: ToplevelManager.toplevels
      delegate: Item {
        required property var modelData
        Layout.fillHeight: true
        Layout.preferredWidth: Theme.taskWidth
        IconImage {
          anchors.centerIn: parent
          implicitSize: Theme.appIcon
          opacity: modelData.activated ? 1.0 : (taskArea.containsMouse ? 0.85 : 0.55)
          source: Quickshell.iconPath(modelData.appId, "application-x-executable")
        }
        MouseArea {
          id: taskArea
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton
          onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) modelData.close()
            else if (modelData.activated) modelData.minimized = true
            else { modelData.minimized = false; modelData.activate() }
          }
        }
      }
    }

    Item { Layout.fillWidth: true }

    ClipboardTray {}
    SoundTray {}
    BluetoothTray {}
    NetworkTray {}
    BatteryTray {}
    BellTray {}

    Repeater {
      model: SystemTray.items
      delegate: Item {
        required property var modelData
        Layout.fillHeight: true
        Layout.preferredWidth: Theme.trayItemWidth
        IconImage { anchors.centerIn: parent; implicitSize: Theme.trayIcon; source: modelData.icon }
        MouseArea { anchors.fill: parent; onClicked: modelData.activate() }
      }
    }

    ClockTray {}

    Rectangle {
      Layout.fillHeight: true
      Layout.preferredWidth: Theme.showDesktopWidth
      color: showArea.containsMouse ? Theme.fillPrimary : Theme.fillCard
      MouseArea {
        id: showArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          for (let i = 0; i < ToplevelManager.toplevels.values.length; i++)
            ToplevelManager.toplevels.values[i].minimized = true
        }
      }
    }
  }
}
