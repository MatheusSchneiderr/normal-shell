import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

SliderRow {
  id: row
  required property string device
  property real fraction: 0
  property real pending: -1
  property int maxLevel: 100
  property bool available: true
  readonly property bool discrete: maxLevel <= 8
  readonly property int level: Math.round(fraction * maxLevel)

  visible: available
  value: fraction
  steps: discrete ? maxLevel : 0
  valueText: discrete ? (level === 0 ? "Off" : level + "/" + maxLevel) : Math.round(fraction * 100) + "%"
  onMoved: v => { fraction = v; pending = v; apply.restart() }

  Cmd {
    id: reader
    command: ["brightnessctl", "-m", "-d", row.device, "info"]
    onFinished: (code, out) => {
      row.available = code === 0
      const f = out.trim().split(",")
      if (f.length < 5) return
      row.maxLevel = parseInt(f[4])
      if (row.pending < 0) row.fraction = parseInt(f[2]) / row.maxLevel
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (row.pending < 0) reader.run()
  }

  Timer {
    id: apply
    interval: 60
    onTriggered: {
      const target = row.discrete ? String(Math.round(row.pending * row.maxLevel)) : Math.round(Math.max(0.01, row.pending) * 100) + "%"
      Quickshell.execDetached(["brightnessctl", "-d", row.device, "set", target])
      row.pending = -1
    }
  }
}
