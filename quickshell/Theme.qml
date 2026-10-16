pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
  id: root

  // theme.json holds the 16 palette colors from Stylix. Each class below uses one palette slot,
  // the user's pick from Prefs.colors or else the default slot. The built-in values are the fallback.
  IpcHandler {
    target: "theme"
    function reload(): void { themeFile.reload() }
  }

  FileView {
    id: themeFile
    blockLoading: true
    path: Quickshell.env("QS_THEME") || (Quickshell.env("HOME") + "/.config/quickshell/theme.json")
    JsonAdapter {
      id: palette
      property string base00: "#181818"
      property string base01: "#282828"
      property string base02: "#383838"
      property string base03: "#585858"
      property string base04: "#b8b8b8"
      property string base05: "#d8d8d8"
      property string base06: "#e8e8e8"
      property string base07: "#f8f8f8"
      property string base08: "#ab4642"
      property string base09: "#dc9656"
      property string base0A: "#f7ca88"
      property string base0B: "#a1b56c"
      property string base0C: "#86c1b9"
      property string base0D: "#7cafc2"
      property string base0E: "#ba8baf"
      property string base0F: "#a16946"
      property string font: "monospace"
    }
  }

  readonly property var slots: [
    { id: "base00", label: "Background" },
    { id: "base01", label: "Lighter background" },
    { id: "base02", label: "Selection" },
    { id: "base03", label: "Comments" },
    { id: "base04", label: "Dark text" },
    { id: "base05", label: "Text" },
    { id: "base06", label: "Light text" },
    { id: "base07", label: "Lightest" },
    { id: "base08", label: "Red" },
    { id: "base09", label: "Orange" },
    { id: "base0A", label: "Yellow" },
    { id: "base0B", label: "Green" },
    { id: "base0C", label: "Cyan" },
    { id: "base0D", label: "Blue" },
    { id: "base0E", label: "Purple" },
    { id: "base0F", label: "Brown" }
  ]

  readonly property var classes: [
    { id: "bg", group: "Backgrounds", label: "Window background", hint: "Panel, popups, windows", slot: "base00" },
    { id: "surface", group: "Backgrounds", label: "Panels, fields, buttons", hint: "Cards, inputs and buttons", slot: "base01" },
    { id: "hover", group: "Backgrounds", label: "Hover and selection", hint: "Highlighted rows and pressed buttons", slot: "base02" },
    { id: "fg", group: "Text", label: "Text", hint: "Normal text and icons", slot: "base05" },
    { id: "bright", group: "Text", label: "Titles", hint: "Headings and emphasis", slot: "base07" },
    { id: "muted", group: "Text", label: "Hints", hint: "Secondary and disabled text", slot: "base03" },
    { id: "accent", group: "Accent", label: "Accent", hint: "Focus, selected items, sliders", slot: "base0D" },
    { id: "danger", group: "Status", label: "Danger", hint: "Errors and destructive actions", slot: "base08" },
    { id: "warning", group: "Status", label: "Warning", hint: "Cautions", slot: "base0A" },
    { id: "success", group: "Status", label: "Success", hint: "Confirmations", slot: "base0B" },
    { id: "titleActive", group: "Window title bars", label: "Active title bar", hint: "Focused window", slot: "base01" },
    { id: "titleInactive", group: "Window title bars", label: "Inactive title bar", hint: "Unfocused windows", slot: "base00" },
    { id: "titleText", group: "Window title bars", label: "Title text", hint: "Text on title bars", slot: "base05" }
  ]

  function slotColor(id) { return palette[id] }

  function resolve(id) {
    let slot = ""
    for (let i = 0; i < classes.length; i++) if (classes[i].id === id) slot = classes[i].slot
    const pick = Prefs.colors[id]
    for (let i = 0; i < slots.length; i++) if (slots[i].id === pick) slot = pick
    return palette[slot]
  }

  readonly property color bg: resolve("bg")
  readonly property color surface: resolve("surface")
  readonly property color hover: resolve("hover")
  readonly property color fg: resolve("fg")
  readonly property color bright: resolve("bright")
  readonly property color muted: resolve("muted")
  readonly property color accent: resolve("accent")
  readonly property color danger: resolve("danger")
  readonly property color warning: resolve("warning")
  readonly property color success: resolve("success")
  readonly property color titleActive: resolve("titleActive")
  readonly property color titleInactive: resolve("titleInactive")
  readonly property color titleText: resolve("titleText")

  // Typography
  readonly property string font: Prefs.fontFamily !== "" ? Prefs.fontFamily : palette.font
  readonly property int fontSmall: Math.round(11 * Prefs.fontScale)
  readonly property int fontBody: Math.round(12 * Prefs.fontScale)
  readonly property int fontLarge: Math.round(14 * Prefs.fontScale)
  readonly property int fontTitle: Math.round(20 * Prefs.fontScale)
  readonly property int fontDisplay: Math.round(30 * Prefs.fontScale)

  // Icons
  readonly property int iconNormal: 18
  readonly property int iconLarge: 24
  readonly property int iconSlot: 22
  readonly property int trayIcon: 22
  readonly property int appIcon: 26

  // Spacing
  readonly property int spaceXs: 4
  readonly property int spaceSm: 6
  readonly property int spaceMd: 10
  readonly property int spaceLg: 14

  // Geometry
  readonly property int barHeight: 44
  readonly property int popupWidth: 380
  readonly property int popupListHeight: 238
  readonly property int popupPadding: 14
  readonly property int rowHeight: 34
  readonly property int inputHeight: 36
  readonly property int buttonHeight: 40
  readonly property int valueWidth: 40
  readonly property int trackHeight: 6
  readonly property int knobSize: 16
  readonly property int sidebarWidth: 220
  readonly property int formLabelWidth: 220
  readonly property int settingsWidth: 1040
  readonly property int settingsHeight: 680
  readonly property int startMenuWidth: 440
  readonly property int startMenuHeight: 640
  readonly property int startRowHeight: 44
  readonly property int swatchSize: 16
  readonly property int thumbWidth: 200
  readonly property int thumbHeight: 120
  readonly property int launcherWidth: 560
  readonly property int launcherHeight: 440
  readonly property int powerRowHeight: 56
  readonly property int toggleWidth: 44
  readonly property int toggleHeight: 24
  readonly property int sliderHeight: 28
  readonly property int tickHeight: 12
  readonly property int startButtonWidth: 52
  readonly property int taskWidth: 44
  readonly property int trayItemWidth: 34
  readonly property int showDesktopWidth: 10
  readonly property int lockFieldWidth: 340
  readonly property int fieldSm: 150
  readonly property int fieldMd: 220
  readonly property int fieldLg: 300
  readonly property int fieldXl: 340
  readonly property int radius: 0
}
