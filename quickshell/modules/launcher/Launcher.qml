import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.components

Scope {
  id: root
  property bool active: false

  IpcHandler {
    target: "launcher"
    function toggle(): void { root.active = !root.active }
    function stop(): void { root.active = false }
  }

  LazyLoader {
    active: root.active

    PanelWindow {
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      MouseArea { anchors.fill: parent; onClicked: root.active = false }

      Rectangle {
        anchors.centerIn: parent
        width: Theme.launcherWidth
        height: Theme.launcherHeight
        color: Theme.fillWindow

        Keys.onEscapePressed: root.active = false

        AppList {
          id: apps
          anchors.fill: parent
          anchors.margins: Theme.spaceMd
          showSettings: false
          onLaunched: root.active = false
          Component.onCompleted: reset()
        }
      }
    }
  }
}
