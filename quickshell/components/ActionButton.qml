import QtQuick
import qs

Clickable {
  id: root
  property string text: ""
  property bool primary: false
  property bool danger: false
  property bool busy: false

  implicitWidth: label.implicitWidth + Theme.spaceLg * 2
  implicitHeight: Theme.buttonHeight - 6
  opacity: enabled ? 1.0 : 0.45
  idleColor: primary ? Theme.fillPrimary : Theme.fillCard
  hoverColor: danger ? Theme.danger : primary ? Theme.fillPrimary : Theme.fillHover

  Label {
    id: label
    anchors.centerIn: parent
    text: root.busy ? "..." : root.text
    color: root.primary || (root.danger && root.highlighted) ? Theme.textPrimary : Theme.textBody
  }
}
