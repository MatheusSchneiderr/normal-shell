import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

Item {
  id: root
  readonly property bool lit: area.containsMouse || Ui.popup === "calendar"

  Layout.fillHeight: true
  Layout.leftMargin: Theme.spaceMd
  Layout.rightMargin: Theme.spaceLg
  implicitWidth: column.implicitWidth

  SystemClock { id: clock; precision: Prefs.showSeconds ? SystemClock.Seconds : SystemClock.Minutes }

  ColumnLayout {
    id: column
    anchors.centerIn: parent
    spacing: 0
    Label {
      Layout.alignment: Qt.AlignRight
      text: Qt.formatDateTime(clock.date, Prefs.timeFormat)
      color: root.lit ? Theme.selected : Theme.textBody
      font.pixelSize: Theme.fontLarge
      font.bold: true
    }
    Label {
      Layout.alignment: Qt.AlignRight
      text: Qt.formatDateTime(clock.date, Prefs.dateFormat)
      color: root.lit ? Theme.selected : Theme.textBody
      font.pixelSize: Theme.fontSmall
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    onClicked: Ui.togglePopup("calendar")
  }
}
