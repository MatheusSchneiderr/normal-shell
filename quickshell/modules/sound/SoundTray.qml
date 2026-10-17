import QtQuick
import qs
import qs.components
import qs.services

StatusButton {
  glyph: Audio.icon
  alert: Audio.muted
  popup: "sound"
  onMiddleClicked: Audio.toggleMute()
  onScrolled: d => Audio.nudge(d * 0.05)
}
