import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
  id: root
  property string label: ""
  property string hint: ""
  default property alias content: slot.data

  Layout.fillWidth: true
  spacing: Theme.spaceLg

  ColumnLayout {
    Layout.preferredWidth: Theme.formLabelWidth
    Layout.maximumWidth: Theme.formLabelWidth
    Layout.fillWidth: false
    Layout.alignment: Qt.AlignTop
    spacing: 0
    Label { text: root.label; Layout.fillWidth: true; elide: Text.ElideRight }
    Label {
      visible: root.hint !== ""
      text: root.hint
      color: Theme.muted
      font.pixelSize: Theme.fontSmall
      wrapMode: Text.Wrap
      Layout.fillWidth: true
    }
  }

  RowLayout {
    id: slot
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignTop
    spacing: Theme.spaceMd
  }
}
