import QtQuick
import QtQuick.Layouts
import qs

Clickable {
  id: item
  property string glyph: ""
  property string title: ""
  property string subtitle: ""
  property bool selected: false
  signal clicked()

  Layout.fillWidth: true
  Layout.preferredHeight: Theme.rowHeight
  onActivated: clicked()

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: Theme.spaceSm
    anchors.rightMargin: Theme.spaceSm
    spacing: Theme.spaceMd
    Glyph {
      text: item.glyph
      color: item.selected ? Theme.selected : Theme.iconBody
    }
    Label {
      Layout.fillWidth: true
      text: item.title
      elide: Text.ElideRight
      color: item.selected ? Theme.selected : Theme.textBody
    }
    Label {
      text: item.subtitle
      color: Theme.textHint
      font.pixelSize: Theme.fontSmall
    }
  }
}
