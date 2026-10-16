import QtQuick
import QtQuick.Layouts
import qs
import qs.components

Clickable {
  property string text: ""
  property bool current: false

  Layout.fillWidth: true
  Layout.preferredHeight: Theme.rowHeight

  Label {
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Theme.spaceSm
    anchors.right: parent.right
    text: (parent.current ? Icons.check + "  " : "     ") + parent.text
    elide: Text.ElideRight
    color: parent.current ? Theme.accent : Theme.fg
  }
}
