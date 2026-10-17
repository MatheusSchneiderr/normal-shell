pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
  id: root

  // theme.json holds the 16 palette colors. Each class below uses one palette slot,
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
    { id: "textBody", group: "Text", label: "Text", hint: "Normal text, and the knob of sliders and toggles", slot: "base05" },
    { id: "textTitle", group: "Text", label: "Titles", hint: "Titles and big clocks", slot: "base07" },
    { id: "textHint", group: "Text", label: "Hints", hint: "Hints, section headers, placeholders, disabled text", slot: "base03" },
    { id: "textInput", group: "Text", label: "Typed text", hint: "What you type in a field", slot: "base05" },
    { id: "textPrimary", group: "Text", label: "Text on main color", hint: "Text on the main button and on today in the calendar, and the toggle knob when on", slot: "base00" },
    { id: "lineDivider", group: "Text", label: "Dividers and borders", hint: "Separators, borders, slider ticks, occupied workspace", slot: "base03" },
    { id: "iconBody", group: "Icons", label: "Icons", hint: "Normal icons and bar icons", slot: "base05" },
    { id: "iconDim", group: "Icons", label: "Dim icons", hint: "Off or muted, dropdown arrow, notification close", slot: "base03" },
    { id: "fillWindow", group: "Fills", label: "Windows and bar", hint: "Bar, popups, menus, Settings, lock screen", slot: "base00" },
    { id: "fillCard", group: "Fills", label: "Cards, fields, buttons", hint: "Cards, sidebar, text fields, dropdowns, buttons, toggle off", slot: "base01" },
    { id: "fillHover", group: "Fills", label: "Hover and current row", hint: "Hovered or current row, hovered button, slider track", slot: "base02" },
    { id: "fillPrimary", group: "Fills", label: "Main color", hint: "Main button, slider fill, toggle on, today in the calendar, current workspace", slot: "base0D" },
    { id: "selected", group: "Accents", label: "Selected", hint: "Selected text, active icons and the focus line", slot: "base0D" },
    { id: "danger", group: "Accents", label: "Danger", hint: "Errors, alert icons, delete button, critical notification", slot: "base08" },
    { id: "warning", group: "Accents", label: "Warning", hint: "Cautions and the warning bar", slot: "base0A" },
    { id: "success", group: "Accents", label: "Success", hint: "Confirmations", slot: "base0B" },
    { id: "titlebarActive", group: "Window title bars", label: "Active title bar", hint: "Focused window", slot: "base01" },
    { id: "titlebarInactive", group: "Window title bars", label: "Inactive title bar", hint: "Unfocused windows", slot: "base00" },
    { id: "titlebarText", group: "Window title bars", label: "Title text", hint: "Text on title bars", slot: "base05" }
  ]

  function slotColor(id) { return palette[id] }

  function resolve(id) {
    let slot = ""
    for (let i = 0; i < classes.length; i++) if (classes[i].id === id) slot = classes[i].slot
    const pick = Prefs.colors[id]
    for (let i = 0; i < slots.length; i++) if (slots[i].id === pick) slot = pick
    return palette[slot]
  }

  readonly property color textBody: resolve("textBody")
  readonly property color textTitle: resolve("textTitle")
  readonly property color textHint: resolve("textHint")
  readonly property color textInput: resolve("textInput")
  readonly property color textPrimary: resolve("textPrimary")
  readonly property color lineDivider: resolve("lineDivider")
  readonly property color iconBody: resolve("iconBody")
  readonly property color iconDim: resolve("iconDim")
  readonly property color fillWindow: resolve("fillWindow")
  readonly property color fillCard: resolve("fillCard")
  readonly property color fillHover: resolve("fillHover")
  readonly property color fillPrimary: resolve("fillPrimary")
  readonly property color selected: resolve("selected")
  readonly property color danger: resolve("danger")
  readonly property color warning: resolve("warning")
  readonly property color success: resolve("success")
  readonly property color titlebarActive: resolve("titlebarActive")
  readonly property color titlebarInactive: resolve("titlebarInactive")
  readonly property color titlebarText: resolve("titlebarText")

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
