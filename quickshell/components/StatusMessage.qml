import QtQuick
import QtQuick.Layouts
import qs

Label {
  property bool ok: false

  visible: text !== ""
  color: ok ? Theme.success : Theme.danger
  wrapMode: Text.Wrap
  Layout.fillWidth: true
}
