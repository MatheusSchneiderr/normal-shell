import QtQuick
import Quickshell
import qs.services

Scope {
  id: root

  readonly property var args: [Prefs.keyboardLayout, Prefs.keyboardVariant]

  onArgsChanged: debounce.restart()
  Component.onCompleted: debounce.restart()

  Timer {
    id: debounce
    interval: 300
    onTriggered: if (Prefs.keyboardLayout !== "") Quickshell.execDetached(["lua", Paths.wayfire + "/input.lua"].concat(root.args))
  }
}
