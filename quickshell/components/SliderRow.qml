import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
  id: root
  property string glyph: ""
  property color glyphColor: Theme.iconBody
  property real value: 0
  property real maximum: 1.0
  property int steps: 0
  property string valueText: Math.round(value / maximum * 100) + "%"
  signal moved(real v)
  signal glyphClicked()

  Layout.fillWidth: true
  spacing: Theme.spaceMd

  Clickable {
    visible: root.glyph !== ""
    Layout.preferredWidth: Theme.rowHeight
    Layout.preferredHeight: Theme.rowHeight
    onActivated: root.glyphClicked()
    Glyph { centered: true; text: root.glyph; color: root.glyphColor }
  }

  Slider {
    Layout.fillWidth: true
    value: root.value
    maximum: root.maximum
    steps: root.steps
    onMoved: v => root.moved(v)
  }

  Label {
    text: root.valueText
    Layout.preferredWidth: Theme.valueWidth
    horizontalAlignment: Text.AlignRight
  }
}
