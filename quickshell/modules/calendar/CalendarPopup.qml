import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

ColumnLayout {
  id: root
  spacing: Theme.spaceSm

  readonly property date today: new Date()
  property int year: today.getFullYear()
  property int month: today.getMonth()

  readonly property int firstWeekday: new Date(year, month, 1).getDay()
  readonly property int monthLength: new Date(year, month + 1, 0).getDate()
  readonly property int previousLength: new Date(year, month, 0).getDate()
  readonly property bool onCurrentMonth: year === today.getFullYear() && month === today.getMonth()

  Keys.onLeftPressed: shift(-1)
  Keys.onRightPressed: shift(1)

  function shift(delta) {
    const d = new Date(year, month + delta, 1)
    year = d.getFullYear()
    month = d.getMonth()
  }

  function goToday() {
    year = today.getFullYear()
    month = today.getMonth()
  }

  SystemClock { id: tick; precision: Prefs.showSeconds ? SystemClock.Seconds : SystemClock.Minutes }

  readonly property string language: Regional.language.split(".")[0]
  readonly property string formats: (Regional.formatList[0] || "").split(".")[0]

  Component.onCompleted: Regional.hold()
  Component.onDestruction: Regional.release()

  Label {
    text: Qt.formatDateTime(tick.date, Prefs.timeFormat)
    color: Theme.bright
    font.pixelSize: Theme.fontDisplay
    font.bold: true
  }

  Label {
    text: Qt.formatDate(root.today, "dddd, d MMMM yyyy")
    color: Theme.fg
    font.pixelSize: Theme.fontBody
    Layout.bottomMargin: Theme.spaceSm
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: 0

    Clickable {
      Layout.preferredWidth: Theme.rowHeight
      Layout.preferredHeight: Theme.rowHeight
      onActivated: root.shift(-1)
      Glyph { anchors.centerIn: parent; text: Icons.chevronLeft; font.pixelSize: Theme.fontLarge }
    }

    Clickable {
      Layout.fillWidth: true
      Layout.preferredHeight: Theme.rowHeight
      onActivated: root.goToday()
      Label {
        anchors.centerIn: parent
        text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
        color: root.onCurrentMonth ? Theme.fg : Theme.accent
        font.pixelSize: Theme.fontLarge
      }
    }

    Clickable {
      Layout.preferredWidth: Theme.rowHeight
      Layout.preferredHeight: Theme.rowHeight
      onActivated: root.shift(1)
      Glyph { anchors.centerIn: parent; text: Icons.chevronRight; font.pixelSize: Theme.fontLarge }
    }
  }

  GridLayout {
    Layout.fillWidth: true
    columns: 7
    columnSpacing: 0
    rowSpacing: 0

    Repeater {
      model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
      delegate: Label {
        required property string modelData
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        horizontalAlignment: Text.AlignHCenter
        text: modelData
        color: Theme.muted
        font.pixelSize: Theme.fontSmall
        font.bold: true
      }
    }

    Repeater {
      model: 42
      delegate: Rectangle {
        required property int index
        readonly property int day: index - root.firstWeekday + 1
        readonly property bool inMonth: day >= 1 && day <= root.monthLength
        readonly property bool isToday: inMonth && root.onCurrentMonth && day === root.today.getDate()

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.rowHeight
        color: isToday ? Theme.bright : "transparent"

        Label {
          anchors.centerIn: parent
          text: inMonth ? day : (day < 1 ? root.previousLength + day : day - root.monthLength)
          color: isToday ? Theme.bg : (inMonth ? Theme.fg : Theme.muted)
          font.bold: isToday
        }
      }
    }
  }

  Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; Layout.topMargin: Theme.spaceSm; color: Theme.hover }

  RowLayout {
    Layout.fillWidth: true
    spacing: Theme.spaceMd

    ColumnLayout {
      spacing: 0
      Label {
        text: "Keyboard  " + (Regional.layout !== "" ? (Regional.layout + " " + Regional.variant).toUpperCase() : "-")
        color: Theme.fg
        font.pixelSize: Theme.fontSmall
      }
      Label {
        text: "Region  " + (root.formats !== "" ? root.formats : "-") + (root.language !== "" && root.language !== root.formats ? "  (" + root.language + ")" : "")
        color: Theme.fg
        font.pixelSize: Theme.fontSmall
      }
      Label {
        text: Regional.zone
        color: Theme.muted
        font.pixelSize: Theme.fontSmall
      }
    }

    Item { Layout.fillWidth: true }

    Clickable {
      Layout.preferredWidth: Theme.buttonHeight
      Layout.preferredHeight: Theme.buttonHeight
      idleColor: Theme.surface
      onActivated: Ui.openSettings("datetime")
      Glyph { anchors.centerIn: parent; text: Icons.gear; color: Theme.accent }
    }
  }
}
