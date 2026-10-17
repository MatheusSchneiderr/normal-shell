import QtQuick
import qs
import qs.components
import qs.services

StatusButton {
  glyph: Prefs.dnd ? Icons.bellOff : Icons.bell
  label: Notifs.count > 0 ? String(Notifs.count) : ""
  dim: Prefs.dnd
  lit: !Prefs.dnd && Notifs.count > 0
  popup: "notifications"
  onMiddleClicked: Prefs.dnd = !Prefs.dnd
}
