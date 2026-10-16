import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  Layout.fillWidth: true
  spacing: Theme.spaceMd

  readonly property var families: [{ label: "Theme default", value: "" }].concat(Qt.fontFamilies().map(f => ({ label: f, value: f })))

  readonly property var scales: [
    { label: "90 %", value: 0.9 },
    { label: "100 %", value: 1.0 },
    { label: "110 %", value: 1.1 },
    { label: "125 %", value: 1.25 }
  ]

  SectionHeader { text: "FONT" }

  FormRow {
    label: "Font"
    hint: "Used by the panel, apps of this desktop and window titles"
    Dropdown { Layout.fillWidth: true; options: families; value: Prefs.fontFamily; onPicked: v => Prefs.fontFamily = v }
  }

  FormRow {
    label: "Text size"
    Dropdown { Layout.fillWidth: true; options: scales; value: Prefs.fontScale; onPicked: v => Prefs.fontScale = v }
  }
}
