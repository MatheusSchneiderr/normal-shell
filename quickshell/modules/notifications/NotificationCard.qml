import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.components

Rectangle {
  id: card
  required property var notification
  property bool toast: false
  property bool hovered: area.containsMouse || closeArea.containsMouse
  signal dismissed()

  readonly property color tint: notification.urgency === NotificationUrgency.Critical ? Theme.danger
    : notification.urgency === NotificationUrgency.Low ? Theme.muted : Theme.accent
  readonly property string picture: notification.image !== "" ? notification.image
    : notification.appIcon !== "" ? Quickshell.iconPath(notification.appIcon, "dialog-information") : ""

  implicitHeight: content.implicitHeight + Theme.spaceMd * 2
  color: toast ? Theme.bg : Theme.surface

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      const first = card.notification.actions.length > 0 ? card.notification.actions[0] : null
      if (first && first.identifier === "default") first.invoke()
      card.dismissed()
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: 3
    color: card.tint
  }

  RowLayout {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: Theme.spaceMd + 3
    anchors.rightMargin: Theme.spaceMd
    anchors.topMargin: Theme.spaceMd
    spacing: Theme.spaceMd

    IconImage {
      visible: card.picture !== ""
      Layout.alignment: Qt.AlignTop
      implicitSize: Theme.appIcon
      source: card.picture
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      RowLayout {
        Layout.fillWidth: true
        Label { text: card.notification.appName; color: Theme.muted; font.pixelSize: Theme.fontSmall; Layout.fillWidth: true; elide: Text.ElideRight }
        Label { text: Notifs.stamp(card.notification); color: Theme.muted; font.pixelSize: Theme.fontSmall }
        Label {
          text: Icons.close
          color: closeArea.containsMouse ? Theme.bright : Theme.muted
          font.pixelSize: Theme.fontBody
          MouseArea { id: closeArea; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; onClicked: card.dismissed() }
        }
      }
      Label {
        visible: text !== ""
        text: card.notification.summary
        color: Theme.bright
        font.bold: true
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        Layout.fillWidth: true
      }
      Label {
        visible: text !== ""
        text: card.notification.body
        textFormat: Text.StyledText
        wrapMode: Text.Wrap
        maximumLineCount: card.toast ? 4 : 6
        elide: Text.ElideRight
        Layout.fillWidth: true
      }
      Flow {
        visible: card.notification.actions.length > 0
        Layout.fillWidth: true
        Layout.topMargin: Theme.spaceXs
        spacing: Theme.spaceSm
        Repeater {
          model: card.notification.actions.filter(a => a.identifier !== "default")
          delegate: ActionButton {
            required property var modelData
            text: modelData.text
            onActivated: { modelData.invoke(); card.dismissed() }
          }
        }
      }
    }
  }
}
