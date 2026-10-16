import QtQuick
import Quickshell
import qs
import qs.services

Scope {
  id: root

  readonly property var args: [String(Theme.titleActive), String(Theme.titleInactive), String(Theme.titleText), Theme.font]

  onArgsChanged: debounce.restart()
  Component.onCompleted: debounce.restart()

  Timer {
    id: debounce
    interval: 400
    onTriggered: Quickshell.execDetached(["lua", Paths.wayfire + "/theme.lua"].concat(root.args))
  }
}
