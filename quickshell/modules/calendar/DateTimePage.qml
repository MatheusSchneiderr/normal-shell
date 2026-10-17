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

  readonly property string layout: Prefs.keyboardLayout !== "" ? Prefs.keyboardLayout : Regional.layout
  readonly property string variant: Prefs.keyboardLayout !== "" ? Prefs.keyboardVariant : Regional.variant
  readonly property string sessionFormats: Quickshell.env("LC_TIME") || Quickshell.env("LANG")

  function setZone(zone) {
    if (Regional.dryRun) return
    zoneSet.run(["timedatectl", "set-timezone", zone])
  }

  function applyLocale(lang, formats) {
    if (Regional.dryRun || !lang || !formats) return
    const pairs = ["LANG=" + lang].concat(Regional.formatKeys.map(k => k + "=" + formats))
    localeSet.pairs = pairs
    localeSet.run(["sh", "-c", 'systemctl --user set-environment "$@" && dbus-update-activation-environment --systemd "$@"', "sh"].concat(pairs))
  }

  SystemClock { id: tick; precision: SystemClock.Seconds }

  Cmd {
    id: ntp
    onFinished: (code, out, err) => { root.message = code === 0 ? "" : (Util.firstLine(err) || "Could not change"); Regional.refresh() }
  }

  Cmd {
    id: zoneSet
    onFinished: (code, out, err) => { root.message = code === 0 ? "" : (Util.firstLine(err) || "Could not change the time zone"); Regional.refresh() }
  }

  Cmd {
    id: localeSet
    property var pairs: []
    onFinished: (code, out, err) => {
      if (code !== 0) { root.message = Util.firstLine(err) || "Could not change the language"; return }
      Quickshell.execDetached(["sh", "-c", 'sleep 1; exec env "$@" quickshell -c panel', "sh"].concat(pairs))
      Qt.quit()
    }
  }

  Component.onCompleted: Regional.hold()
  Component.onDestruction: Regional.release()

  NoticeBar {
    visible: Regional.onNixos
    text: "You are using NixOS. Some configurations might conflict with declared ones. Confirm before rebuilding your system."
  }

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
      color: Theme.textTitle
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

  SectionHeader { text: "REGION AND LANGUAGE" }

  FormRow {
    label: "Time zone"
    hint: "Lasts until the next reboot or rebuild"
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Theme.spaceXs
      TextField { Layout.fillWidth: true; id: zoneFilter; placeholder: "Filter, for example Lisbon" }
      Dropdown {
        Layout.fillWidth: true
        value: Regional.zone
        options: Regional.zones.filter(z => z.toLowerCase().includes(zoneFilter.text.toLowerCase())).map(z => ({ label: z, value: z }))
        onPicked: z => root.setZone(z)
      }
    }
  }

  FormRow {
    visible: Regional.onNixos
    label: "Language and formats"
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Theme.spaceXs
      Dropdown {
        Layout.fillWidth: true
        value: Quickshell.env("LANG")
        options: Regional.locales.map(l => ({ label: "Language   " + l, value: l }))
        onPicked: l => root.applyLocale(l, root.sessionFormats)
      }
      Dropdown {
        Layout.fillWidth: true
        value: root.sessionFormats
        options: Regional.locales.map(l => ({ label: "Formats   " + l, value: l }))
        onPicked: l => root.applyLocale(Quickshell.env("LANG"), l)
      }
      Label {
        Layout.fillWidth: true
        text: "Temporary: lasts until you log out. To make it permanent, change i18n.defaultLocale in your system flake (configuration.nix). Open windows and programs started by key bindings keep the old language until restarted."
        color: Theme.textHint
        font.pixelSize: Theme.fontSmall
        wrapMode: Text.Wrap
      }
    }
  }

  FormRow {
    label: "Keyboard layout"
    hint: "Applied now and again whenever the panel starts"
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Theme.spaceXs
      Dropdown {
        Layout.fillWidth: true
        value: root.layout
        options: Regional.layouts
        onPicked: v => { Prefs.keyboardLayout = v; Prefs.keyboardVariant = "" }
      }
      Dropdown {
        Layout.fillWidth: true
        value: root.variant
        options: [{ label: "default", value: "" }].concat(Regional.variants.filter(v => v.layout === root.layout))
        onPicked: v => { if (Prefs.keyboardLayout === "") Prefs.keyboardLayout = root.layout; Prefs.keyboardVariant = v }
      }
    }
  }
}
