import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: root
  property string title: ""
  default property alias content: column.data

  Flickable {
    id: flick
    anchors.fill: parent
    contentWidth: width
    contentHeight: column.implicitHeight + Theme.spaceLg * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
      id: column
      x: Theme.spaceLg * 2
      y: Theme.spaceLg
      width: flick.width - Theme.spaceLg * 4
      spacing: Theme.spaceMd

      Label {
        text: root.title
        color: Theme.bright
        font.pixelSize: Theme.fontTitle
        font.bold: true
        Layout.bottomMargin: Theme.spaceSm
      }
    }
  }

  Rectangle {
    visible: flick.contentHeight > flick.height
    anchors.right: parent.right
    width: 4
    height: flick.height * flick.height / flick.contentHeight
    y: flick.contentHeight > flick.height ? flick.height * flick.contentY / flick.contentHeight : 0
    color: Theme.muted
  }
}
