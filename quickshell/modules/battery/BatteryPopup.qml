import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  spacing: Theme.spaceMd

  readonly property var bat: UPower.displayDevice
  readonly property var others: UPower.devices.values.filter(d => !d.isLaptopBattery && !d.powerSupply && d.isPresent && d.percentage > 0)

  function duration(seconds) {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    return (h > 0 ? h + " h " : "") + m + " min"
  }

  function statusLine() {
    if (!bat || !bat.isPresent) return "No battery"
    if (bat.state === UPowerDeviceState.Charging) return bat.timeToFull > 0 ? duration(bat.timeToFull) + " until full" : "Charging"
    if (bat.state === UPowerDeviceState.Discharging) return bat.timeToEmpty > 0 ? duration(bat.timeToEmpty) + " remaining" : "Discharging"
    if (bat.state === UPowerDeviceState.FullyCharged) return "Fully charged"
    return "Not charging"
  }

  SectionHeader { text: "BATTERY" }

  RowLayout {
    Layout.fillWidth: true
    spacing: Theme.spaceMd
    Label {
      text: Math.round((root.bat ? root.bat.percentage : 0) * 100) + "%"
      color: (root.bat && root.bat.percentage < 0.15 && root.bat.state !== UPowerDeviceState.Charging) ? Theme.danger : Theme.fg
      font.pixelSize: Theme.fontDisplay
      font.bold: true
    }
    ColumnLayout {
      spacing: 0
      Label { text: root.statusLine(); color: Theme.fg;font.pixelSize: Theme.fontBody }
      Label {
        visible: root.bat && root.bat.healthSupported
        text: "Health " + Math.round(root.bat ? root.bat.healthPercentage : 0) + "%"
        color: Theme.muted
        font.pixelSize: Theme.fontSmall
      }
    }
  }

  Slider {
    Layout.fillWidth: true
    enabled: false
    knobVisible: false
    value: root.bat ? root.bat.percentage : 0
  }

  Repeater {
    model: root.others
    delegate: RowLayout {
      required property var modelData
      Layout.fillWidth: true
      Label {
        Layout.fillWidth: true
        text: modelData.model || "Device"
        color: Theme.fg
        font.pixelSize: Theme.fontBody
        elide: Text.ElideRight
      }
      Label {
        text: Math.round(modelData.percentage * 100) + "%"
        color: Theme.fg
        font.pixelSize: Theme.fontBody
      }
    }
  }

  SectionHeader { text: "BRIGHTNESS" }
  BrightnessRow { device: "intel_backlight"; glyph: Icons.sun }
  BrightnessRow { device: "asus::kbd_backlight"; glyph: Icons.keyboard }

  ListRow {
    glyph: Icons.coffee
    title: "Keep awake (block sleep and screen lock)"
    selected: Battery.keepAwake
    onClicked: Battery.keepAwake = !Battery.keepAwake
  }
}
