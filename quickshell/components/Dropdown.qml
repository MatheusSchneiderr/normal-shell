import QtQuick
import QtQuick.Layouts
import qs

Item {
  id: root
  property var options: []
  property var value
  property bool expanded: false
  signal picked(var value)

  readonly property int maxRows: 8
  readonly property string currentLabel: {
    for (let i = 0; i < options.length; i++) if (options[i].value === value) return options[i].label
    return value === undefined ? "" : String(value)
  }

  implicitWidth: Theme.fieldMd
  implicitHeight: Theme.inputHeight
  Layout.preferredWidth: Theme.fieldMd
  Layout.preferredHeight: Theme.inputHeight

  function choose(chosen) {
    expanded = false
    picked(chosen)
  }

  function place() {
    const spot = head.mapToItem(layer, 0, 0)
    panel.x = spot.x
    panel.width = head.width
    const below = spot.y + head.height
    panel.y = below + panel.height > layer.height ? Math.max(0, spot.y - panel.height) : below
  }

  function focusCurrent() {
    let index = 0
    for (let i = 0; i < options.length; i++) if (options[i].value === value) index = i
    list.positionViewAtIndex(index, ListView.Contain)
    const item = list.itemAtIndex(index)
    if (item) item.forceActiveFocus()
  }

  onExpandedChanged: if (expanded) { place(); Qt.callLater(focusCurrent) }

  Clickable {
    id: head
    anchors.fill: parent
    idleColor: Theme.surface
    onActivated: root.expanded = !root.expanded
    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: Theme.spaceMd
      anchors.right: arrow.left
      text: root.currentLabel
      elide: Text.ElideRight
    }
    Glyph {
      id: arrow
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: Theme.spaceSm
      text: root.expanded ? Icons.caretUp : Icons.caretDown
      color: Theme.muted
    }
  }

  // The option list lives on the window's top layer, so it floats over the page instead of pushing it down.
  Item {
    id: layer
    visible: root.expanded
    parent: Window.window ? Window.window.contentItem : root
    anchors.fill: parent
    z: 10000

    MouseArea { anchors.fill: parent; onClicked: root.expanded = false }

    Rectangle {
      id: panel
      height: Math.min(list.contentHeight, root.maxRows * Theme.rowHeight)
      color: Theme.surface

      ListView {
        id: list
        anchors.fill: parent
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        model: root.options
        delegate: Clickable {
          required property var modelData
          width: list.width
          height: Theme.rowHeight
          idleColor: Theme.surface
          onActivated: root.choose(modelData.value)
          Keys.onEscapePressed: root.expanded = false
          Keys.onDownPressed: { const n = nextItemInFocusChain(true); if (n) n.forceActiveFocus() }
          Keys.onUpPressed: { const n = nextItemInFocusChain(false); if (n) n.forceActiveFocus() }
          Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spaceMd
            text: modelData.label
            color: modelData.value === root.value ? Theme.accent : Theme.fg
          }
        }
      }
    }
  }
}
