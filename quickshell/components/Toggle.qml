import QtQuick
import qs

Clickable {
  id: root
  property bool checked: false
  signal toggled(bool value)

  implicitWidth: Theme.toggleWidth
  implicitHeight: Theme.toggleHeight
  color: "transparent"
  onActivated: toggled(!checked)

  Rectangle {
    anchors.fill: parent
    color: root.checked ? Theme.fillPrimary : Theme.fillCard
    Rectangle {
      width: parent.height - 8
      height: width
      y: 4
      x: root.checked ? parent.width - width - 4 : 4
      color: root.checked ? Theme.textPrimary : Theme.textBody
    }
    Rectangle {
      anchors.fill: parent
      color: Theme.fillPrimary
      opacity: root.highlighted ? 0.12 : 0
    }
  }
}
