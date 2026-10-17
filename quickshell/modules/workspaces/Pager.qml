import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.services

Item {
  id: root
  property int columns: 2
  property int rows: 2
  property int currentX: 0
  property int currentY: 0
  property var busy: []

  readonly property real cellWidth: 20
  readonly property real cellHeight: 13
  implicitWidth: columns * cellWidth + (columns - 1) * Theme.spaceXs + Theme.spaceMd * 2

  function occupied(x, y) {
    for (let i = 0; i < busy.length; i++) if (busy[i][0] === x && busy[i][1] === y) return true
    return false
  }

  Process {
    command: ["lua", Paths.wayfire + "/workspace-watch.lua"]
    running: true
    stdout: SplitParser {
      onRead: line => {
        try {
          const s = JSON.parse(line)
          root.columns = s.w
          root.rows = s.h
          root.currentX = s.x
          root.currentY = s.y
          root.busy = s.busy
        } catch (e) {}
      }
    }
  }

  Grid {
    anchors.centerIn: parent
    columns: root.columns
    spacing: Theme.spaceXs
    Repeater {
      model: root.columns * root.rows
      delegate: Rectangle {
        required property int index
        readonly property int cx: index % root.columns
        readonly property int cy: Math.floor(index / root.columns)
        width: root.cellWidth
        height: root.cellHeight
        color: (cx === root.currentX && cy === root.currentY) ? Theme.fillPrimary
          : (cellArea.containsMouse ? Theme.fillHover : (root.occupied(cx, cy) ? Theme.lineDivider : Theme.fillCard))
        MouseArea {
          id: cellArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: Quickshell.execDetached(["lua", Paths.wayfire + "/edge-focus.lua", "goto", parent.cx, parent.cy])
        }
      }
    }
  }
}
