pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Colors and font come from ~/.config/quickshell/theme.json (see quickshell/theme.json).
  // The defaults below only show for the few ms before the file is read.
  // A file watcher misses symlink swaps, so after changing the file run `quickshell -c panel ipc call theme reload`.
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
      property string bg: "#181818"
      property string surface: "#282828"
      property string hover: "#383838"
      property string muted: "#585858"
      property string fg: "#d8d8d8"
      property string bright: "#f8f8f8"
      property string accent: "#7cafc2"
      property string danger: "#ab4642"
      property string warning: "#f7ca88"
      property string success: "#a1b56c"
      property string font: "monospace"
    }
  }

  readonly property color bg: palette.bg
  readonly property color surface: palette.surface
  readonly property color hover: palette.hover
  readonly property color muted: palette.muted
  readonly property color fg: palette.fg
  readonly property color bright: palette.bright
  readonly property color accent: palette.accent
  readonly property color danger: palette.danger
  readonly property color warning: palette.warning
  readonly property color success: palette.success

  // Typography
  readonly property string font: palette.font
  readonly property int fontSmall: 11
  readonly property int fontBody: 12
  readonly property int fontLarge: 14
  readonly property int fontTitle: 20
  readonly property int fontDisplay: 30

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
