import QtQuick
import qs

Rectangle {
  id: root
  signal activated()
  property color idleColor: "transparent"
  property color hoverColor: Theme.hover
  readonly property bool hovered: area.containsMouse
  readonly property bool highlighted: area.containsMouse || activeFocus

  activeFocusOnTab: true
  color: highlighted ? hoverColor : idleColor

  Keys.onReturnPressed: activated()
  Keys.onEnterPressed: activated()
  Keys.onSpacePressed: activated()

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { root.forceActiveFocus(); root.activated() }
  }
}
