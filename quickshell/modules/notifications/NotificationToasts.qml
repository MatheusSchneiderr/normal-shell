import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs

PanelWindow {
  id: window
  visible: Notifs.toasts.length > 0
  screen: Quickshell.screens[0]
  anchors { top: true; right: true }
  margins { top: Theme.spaceMd; right: Theme.spaceMd }
  implicitWidth: Theme.popupWidth
  implicitHeight: column.implicitHeight
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  ColumnLayout {
    id: column
    width: parent.width
    spacing: Theme.spaceSm

    Repeater {
      model: Notifs.toasts
      delegate: NotificationCard {
        id: item
        required property var modelData
        notification: modelData
        toast: true
        Layout.fillWidth: true

        onDismissed: { Notifs.hide(modelData); modelData.dismiss() }

        Timer {
          interval: modelData.expireTimeout > 0 ? modelData.expireTimeout * 1000 : modelData.urgency === NotificationUrgency.Critical ? 0 : 6000
          running: interval > 0 && !item.hovered
          onTriggered: Notifs.hide(modelData)
        }

        Connections {
          target: modelData
          function onClosed() { Notifs.hide(modelData) }
        }
      }
    }
  }
}
