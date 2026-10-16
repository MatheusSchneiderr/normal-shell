import QtQuick
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

StatusButton {
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property int connected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

  visible: adapter !== null
  glyph: Icons.bluetooth
  label: connected > 0 ? String(connected) : ""
  tint: (adapter && adapter.enabled) ? Theme.fg : Theme.muted
  popup: "bluetooth"
}
