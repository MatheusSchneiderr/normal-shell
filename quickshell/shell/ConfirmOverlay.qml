import QtQuick
import QtQuick.Layouts
import qs
import qs.components

Rectangle {
  id: root
  property string title: ""
  property int countdown: 0
  signal confirmed()
  signal cancelled()

  color: Theme.fillWindow

  function focusConfirm() { confirmButton.forceActiveFocus() }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: Theme.spaceLg

    Label {
      Layout.alignment: Qt.AlignHCenter
      text: root.title
      font.pixelSize: Theme.fontTitle
      font.bold: true
    }
    Label {
      Layout.alignment: Qt.AlignHCenter
      text: "Automatically in " + root.countdown + " seconds"
      color: Theme.textHint
    }
    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: Theme.spaceMd
      ActionButton {
        id: confirmButton
        Layout.preferredWidth: Theme.fieldSm
        Layout.preferredHeight: Theme.buttonHeight
        text: "Confirm"
        danger: true
        onActivated: root.confirmed()
        Keys.onRightPressed: cancelButton.forceActiveFocus()
      }
      ActionButton {
        id: cancelButton
        Layout.preferredWidth: Theme.fieldSm
        Layout.preferredHeight: Theme.buttonHeight
        text: "Cancel"
        onActivated: root.cancelled()
        Keys.onLeftPressed: confirmButton.forceActiveFocus()
      }
    }
  }
}
