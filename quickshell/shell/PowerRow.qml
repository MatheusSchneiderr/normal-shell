import QtQuick
import QtQuick.Layouts
import qs
import qs.components

RowLayout {
  id: root
  property var actions: []
  signal chosen(var action)
  signal searchRequested()

  Layout.fillWidth: true
  Layout.minimumHeight: Theme.powerRowHeight
  Layout.maximumHeight: Theme.powerRowHeight
  spacing: Theme.spaceXs

  Repeater {
    model: root.actions
    delegate: Clickable {
      required property var modelData
      Layout.fillWidth: true
      Layout.fillHeight: true
      idleColor: Theme.fillCard
      onActivated: root.chosen(modelData)
      Keys.onUpPressed: root.searchRequested()
      Keys.onLeftPressed: { const n = nextItemInFocusChain(false); if (n) n.forceActiveFocus() }
      Keys.onRightPressed: { const n = nextItemInFocusChain(true); if (n) n.forceActiveFocus() }

      ColumnLayout {
        anchors.centerIn: parent
        spacing: 2
        Glyph {
          Layout.alignment: Qt.AlignHCenter
          text: modelData.icon
          color: modelData.id === "shutdown" ? Theme.danger : Theme.selected
        }
        Label {
          Layout.alignment: Qt.AlignHCenter
          text: modelData.label
          font.pixelSize: Theme.fontSmall
        }
      }
    }
  }
}
