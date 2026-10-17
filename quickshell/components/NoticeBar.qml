import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
  id: root
  property alias text: label.text
  property color tint: Theme.warning

  Layout.fillWidth: true
  implicitHeight: label.implicitHeight + Theme.spaceMd * 2
  color: Theme.fillCard

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: Theme.spaceXs
    color: root.tint
  }

  Label {
    id: label
    anchors.fill: parent
    anchors.leftMargin: Theme.spaceLg
    anchors.rightMargin: Theme.spaceMd
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.Wrap
  }
}
