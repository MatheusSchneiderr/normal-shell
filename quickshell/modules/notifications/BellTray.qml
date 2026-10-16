import QtQuick
import qs
import qs.components
import qs.services

StatusButton {
  glyph: Prefs.dnd ? Icons.bellOff : Icons.bell
  label: Notifs.count > 0 ? String(Notifs.count) : ""
  tint: Prefs.dnd ? Theme.muted : (Notifs.count > 0 ? Theme.accent : Theme.fg)
  popup: "notifications"
  onMiddleClicked: Prefs.dnd = !Prefs.dnd
}
