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
    highlightMoveDuration: 0
    model: ScriptModel {
      values: DesktopEntries.applications.values
        .filter(e => !e.noDisplay && e.name.toLowerCase().includes(search.text.toLowerCase()))
        .sort((a, b) => a.name.localeCompare(b.name))
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
        onEntered: list.currentIndex = index
        onClicked: { modelData.execute(); root.launched() }
      }
    }
  }
}
