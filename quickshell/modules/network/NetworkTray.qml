import QtQuick
import Quickshell.Networking
import qs
import qs.components
import qs.services

StatusButton {
  readonly property var wifi: Networking.devices.values.find(d => d.type === 1)

  glyph: !Networking.wifiEnabled ? Icons.airplane : Icons.wifi
  tint: (!Networking.wifiEnabled || !wifi || !wifi.connected) ? Theme.muted : Theme.fg
  popup: "network"
}
