import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

SettingsPage {
  id: root
  title: "Date & time"

  property string message: ""

  readonly property var dateFormats: [
    { label: "Thu 15 Oct", value: "ddd dd MMM" },
    { label: "15/10/2026", value: "dd/MM/yyyy" },
    { label: "2026-10-15", value: "yyyy-MM-dd" },
    { label: "Thu, Oct 15", value: "ddd, MMM d" }
  ]

  SystemClock { id: tick; precision: SystemClock.Seconds }

  Cmd {
    id: ntp
    onFinished: (code, out, err) => { root.message = code === 0 ? "" : (Util.firstLine(err) || "Could not change"); Regional.refresh() }
  }

  Component.onCompleted: Regional.hold()
  Component.onDestruction: Regional.release()

  SectionHeader { text: "PANEL CLOCK" }
  FormRow {
    label: "24-hour clock"
    Toggle { checked: Prefs.clock24h; onToggled: v => Prefs.clock24h = v }
  }
  FormRow {
    label: "Show seconds"
    Toggle { checked: Prefs.showSeconds; onToggled: v => Prefs.showSeconds = v }
  }
  FormRow {
    label: "Date format"
    Dropdown { Layout.fillWidth: true; value: Prefs.dateFormat; options: root.dateFormats; onPicked: v => Prefs.dateFormat = v }
  }
  FormRow {
    label: "Preview"
    Label {
      text: Qt.formatDateTime(tick.date, Prefs.timeFormat) + "    " + Qt.formatDateTime(tick.date, Prefs.dateFormat)
      color: Theme.bright
      font.pixelSize: Theme.fontLarge
    }
  }

  SectionHeader { text: "TIME" }
  StatusMessage { text: root.message }
  FormRow {
    label: "Set time automatically"
    hint: "Synchronize with network time servers"
    Toggle {
      checked: Regional.info["NTP"] === "yes"
      enabled: Regional.info["CanNTP"] !== "no"
      onToggled: v => ntp.run(["timedatectl", "set-ntp", v ? "true" : "false"])
    }
  }
  FormRow {
    label: "Clock synchronized"
    Label {
      text: Regional.info["NTPSynchronized"] === "yes" ? "Yes" : "No"
      color: Regional.info["NTPSynchronized"] === "yes" ? Theme.success : Theme.warning
    }
  }
  FormRow {
    label: "System time"
    Label { text: Regional.info["TimeUSec"] || "-" }
  }

  SectionHeader { text: "REGION AND LANGUAGE (READ ONLY)" }
  Label {
    text: "Time zone, language and keyboard layout are set declaratively in the NixOS configuration, so they are shown here but cannot be changed from this app."
    color: Theme.muted
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }
  FormRow {
    label: "Time zone"
    Label { text: Regional.zone || "-" }
  }
  FormRow {
    label: "Language and formats"
    Label { text: Regional.language !== "" ? "Language   " + Regional.language + "\nFormats    " + Regional.formatList.join(", ") : "-"; lineHeight: 1.3 }
  }
  FormRow {
    label: "Keyboard layout"
    Label { text: Regional.layout !== "" ? "layout " + Regional.layout + "   variant " + Regional.variant : "-" }
  }
}
