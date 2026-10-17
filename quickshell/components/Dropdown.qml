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

  readonly property var currentSwatch: {
    for (let i = 0; i < options.length; i++) if (options[i].value === value) return options[i].swatch
    return undefined
  }

  implicitWidth: Theme.fieldMd
  implicitHeight: Theme.inputHeight
  Layout.preferredWidth: Theme.fieldMd
  Layout.preferredHeight: Theme.inputHeight

  function choose(chosen) {
    expanded = false
    picked(chosen)
  }

  Clickable {
    id: head
    anchors.fill: parent
    idleColor: Theme.fillCard
    onActivated: root.expanded = !root.expanded
    Rectangle {
      id: headSwatch
      visible: root.currentSwatch !== undefined
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: Theme.spaceMd
      width: Theme.swatchSize
      height: Theme.swatchSize
      color: root.currentSwatch !== undefined ? root.currentSwatch : "transparent"
      border.width: 1
      border.color: Theme.lineDivider
    }
    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: headSwatch.visible ? headSwatch.right : parent.left
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
      color: Theme.iconDim
    }
  }

  // The option list is built only while it is open, on the window's top layer, so it floats over the page.
  Loader {
    active: root.expanded
    parent: Window.window ? Window.window.contentItem : root
    anchors.fill: parent
    z: 10000
    onLoaded: { item.place(); Qt.callLater(item.focusCurrent) }

    sourceComponent: Item {
      id: layer

      function place() {
        const spot = head.mapToItem(layer, 0, 0)
        panel.x = spot.x
        panel.width = head.width
        const below = spot.y + head.height
        panel.y = below + panel.height > layer.height ? Math.max(0, spot.y - panel.height) : below
      }

      function focusCurrent() {
        let index = 0
        for (let i = 0; i < root.options.length; i++) if (root.options[i].value === root.value) index = i
        list.positionViewAtIndex(index, ListView.Contain)
        const row = list.itemAtIndex(index)
        if (row) row.forceActiveFocus()
      }

      MouseArea { anchors.fill: parent; onClicked: root.expanded = false }

      Rectangle {
        id: panel
        height: Math.min(list.contentHeight, root.maxRows * Theme.rowHeight)
        color: Theme.fillCard

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
            idleColor: Theme.fillCard
            onActivated: root.choose(modelData.value)
            Keys.onEscapePressed: root.expanded = false
            Keys.onDownPressed: { const n = nextItemInFocusChain(true); if (n) n.forceActiveFocus() }
            Keys.onUpPressed: { const n = nextItemInFocusChain(false); if (n) n.forceActiveFocus() }
            Rectangle {
              id: rowSwatch
              visible: modelData.swatch !== undefined
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: Theme.spaceMd
              width: Theme.swatchSize
              height: Theme.swatchSize
              color: modelData.swatch !== undefined ? modelData.swatch : "transparent"
              border.width: 1
              border.color: Theme.lineDivider
            }
            Label {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: rowSwatch.visible ? rowSwatch.right : parent.left
              anchors.leftMargin: Theme.spaceMd
              text: modelData.label
              color: modelData.value === root.value ? Theme.selected : Theme.textBody
            }
          }
        }
      }
    }
  }
}
