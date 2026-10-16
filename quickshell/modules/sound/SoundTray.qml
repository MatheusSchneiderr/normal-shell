import QtQuick
import qs
import qs.components
import qs.services

StatusButton {
  glyph: Audio.icon
  tint: Audio.muted ? Theme.danger : Theme.fg
  popup: "sound"
  onMiddleClicked: Audio.toggleMute()
  onScrolled: d => Audio.nudge(d * 0.05)
}
