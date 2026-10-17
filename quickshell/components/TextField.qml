import QtQuick
import qs

Rectangle {
  id: root
  property alias text: input.text
  property string placeholder: ""
  property bool password: false
  property int fontSize: Theme.fontBody
  property alias input: input
  signal accepted()
  signal downPressed()
  signal upPressed()

  implicitWidth: Theme.fieldMd
  implicitHeight: Theme.inputHeight
  color: Theme.fillCard
  activeFocusOnTab: true
  onActiveFocusChanged: if (activeFocus) input.forceActiveFocus()

  TextInput {
    id: input
    anchors.fill: parent
    anchors.leftMargin: Theme.spaceMd
    anchors.rightMargin: Theme.spaceMd
    verticalAlignment: TextInput.AlignVCenter
    echoMode: root.password ? TextInput.Password : TextInput.Normal
    color: Theme.textInput
    selectByMouse: true
    font.family: Theme.font
    font.pixelSize: root.fontSize
    clip: true
    activeFocusOnTab: true
    onAccepted: root.accepted()
    Keys.onDownPressed: root.downPressed()
    Keys.onUpPressed: root.upPressed()
    Text {
      visible: input.text === ""
      anchors.verticalCenter: parent.verticalCenter
      text: root.placeholder
      color: Theme.textHint
      font: input.font
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 2
    color: Theme.selected
    visible: input.activeFocus
  }
}
