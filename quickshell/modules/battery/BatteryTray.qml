import QtQuick
import Quickshell.Services.UPower
import qs
import qs.components
import qs.services

StatusButton {
  readonly property var bat: UPower.displayDevice
  readonly property real pct: bat ? bat.percentage : 0
  readonly property bool charging: bat && bat.state === UPowerDeviceState.Charging

  visible: bat && bat.isPresent
  glyph: charging ? Icons.bolt : (pct > 0.875 ? Icons.batteryFull : pct > 0.625 ? Icons.batteryThreeQuarters : pct > 0.375 ? Icons.batteryHalf : pct > 0.125 ? Icons.batteryQuarter : Icons.batteryEmpty)
  label: Math.round(pct * 100) + "%"
  tint: (pct < 0.15 && !charging) ? Theme.danger : Theme.fg
  popup: "battery"
}
