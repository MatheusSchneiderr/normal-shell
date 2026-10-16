import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.components

ColumnLayout {
  id: root
  signal launched()
  signal settingsRequested()
  property bool showSettings: true

  spacing: Theme.spaceMd

  function focusSearch() { search.input.forceActiveFocus() }
  function reset() { search.text = ""; focusSearch() }

  RowLayout {
    Layout.fillWidth: true
    spacing: Theme.spaceXs

    TextField {
      id: search
      Layout.fillWidth: true
      Layout.preferredHeight: Theme.buttonHeight
      fontSize: Theme.fontLarge
      placeholder: "Search applications..."
      onTextChanged: list.currentIndex = 0
      onDownPressed: list.incrementCurrentIndex()
      onUpPressed: list.decrementCurrentIndex()
      onAccepted: {
        const entry = list.model.values[list.currentIndex]
        if (entry) { entry.execute(); root.launched() }
      }
    }

    Clickable {
      visible: root.showSettings
      Layout.preferredWidth: Theme.buttonHeight
      Layout.preferredHeight: Theme.buttonHeight
      idleColor: Theme.surface
      onActivated: root.settingsRequested()
      Glyph { anchors.centerIn: parent; text: Icons.gear; color: Theme.accent }
    }
  }

  ListView {
    id: list
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: Theme.startMenuHeight / 3
    clip: true
    currentIndex: 0
    property real mouseX: -1
    property real mouseY: -1
    highlightMoveDuration: 0
    // Names that start with the text come first, then names with a word that starts with it, then the rest
    function rank(name, query) {
      const n = name.toLowerCase()
      if (n.startsWith(query)) return 0
      return n.includes(" " + query) ? 1 : 2
    }

    model: ScriptModel {
      values: {
        const query = search.text.toLowerCase()
        return DesktopEntries.applications.values
          .filter(e => !e.noDisplay && e.name.toLowerCase().includes(query))
          .sort((a, b) => list.rank(a.name, query) - list.rank(b.name, query) || a.name.localeCompare(b.name))
      }
    }
    delegate: Rectangle {
      required property var modelData
      required property int index
      width: list.width
      height: Theme.startRowHeight
      color: ListView.isCurrentItem ? Theme.hover : "transparent"
      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spaceMd
        spacing: Theme.spaceMd
        IconImage {
          implicitSize: Theme.appIcon
          source: Quickshell.iconPath(modelData.icon, "application-x-executable")
        }
        Label {
          Layout.fillWidth: true
          text: modelData.name
          elide: Text.ElideRight
          font.pixelSize: Theme.fontLarge
        }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: mouse => {
          // The list moving under a resting mouse also reports a position; only a real move may change the selection
          const spot = mapToItem(null, mouse.x, mouse.y)
          const moved = list.mouseX >= 0 && (spot.x !== list.mouseX || spot.y !== list.mouseY)
          list.mouseX = spot.x
          list.mouseY = spot.y
          if (moved) list.currentIndex = index
        }
        onClicked: { modelData.execute(); root.launched() }
      }
    }
  }
}
