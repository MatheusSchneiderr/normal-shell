import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  spacing: Theme.spaceMd

  RowLayout {
    Layout.fillWidth: true
    SectionHeader { text: "NOTIFICATIONS" + (Notifs.count > 0 ? "  " + Notifs.count : ""); Layout.fillWidth: true }
    ActionButton { visible: Notifs.count > 0; text: "Clear all"; onActivated: Notifs.clear() }
  }

  ListRow {
    glyph: Prefs.dnd ? Icons.bellOff : Icons.bell
    title: "Do not disturb"
    subtitle: Prefs.dnd ? "on" : "off"
    selected: Prefs.dnd
    onClicked: Prefs.dnd = !Prefs.dnd
  }

  Label {
    visible: Notifs.count === 0
    text: "No notifications"
    color: Theme.muted
    Layout.leftMargin: Theme.spaceSm
  }

  ListView {
    id: list
    visible: Notifs.count > 0
    Layout.fillWidth: true
    Layout.preferredHeight: Math.min(contentHeight, 420)
    clip: true
    spacing: Theme.spaceXs
    model: Notifs.model.values.slice().reverse()
    delegate: NotificationCard {
      required property var modelData
      width: list.width
      notification: modelData
      onDismissed: modelData.dismiss()
    }
  }
}
