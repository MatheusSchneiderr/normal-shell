import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.components
import qs.services

Scope {
  id: root
  property bool active: false

  readonly property int stepSmall: 40
  readonly property int stepBig: 160

  function press(direction, big) {
    Quickshell.execDetached(["lua", Paths.wayfire + "/window.lua", "resize", direction, String(big ? stepBig : stepSmall)])
  }

  IpcHandler {
    target: "resize"
    function toggle(): void { root.active = !root.active }
    function stop(): void { root.active = false }
  }

  LazyLoader {
    active: root.active

    PanelWindow {
      anchors { bottom: true }
      margins { bottom: Theme.barHeight + Theme.spaceLg }
      implicitWidth: hint.implicitWidth + Theme.spaceLg * 2
      implicitHeight: Theme.buttonHeight
      exclusionMode: ExclusionMode.Ignore
      color: Theme.bg
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
          const big = (event.modifiers & Qt.ShiftModifier) !== 0
          switch (event.key) {
          case Qt.Key_H: case Qt.Key_Left: root.press("h", big); break
          case Qt.Key_L: case Qt.Key_Right: root.press("l", big); break
          case Qt.Key_J: case Qt.Key_Down: root.press("j", big); break
          case Qt.Key_K: case Qt.Key_Up: root.press("k", big); break
          case Qt.Key_Escape: case Qt.Key_Return: case Qt.Key_Enter: case Qt.Key_Q: root.active = false; break
          default: return
          }
          event.accepted = true
        }

        Label {
          id: hint
          anchors.centerIn: parent
          textFormat: Text.StyledText
          text: "<b>RESIZE</b>   h/l width   j/k height   shift = bigger   esc = done"
        }
      }
    }
  }
}
