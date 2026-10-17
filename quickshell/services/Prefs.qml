pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: root
  property bool clock24h: true
  property bool showSeconds: false
  property string dateFormat: "ddd dd MMM"
  property bool dnd: false
  property string wallpaper: ""
  property string wallpaperFit: "fill"
  property string wallpaperDir: Quickshell.env("HOME") + "/Pictures"
  property var colors: ({})
  property string fontFamily: ""
  property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
  property bool screenshotCopy: true
  property bool screenshotEdit: true
  property string keyboardLayout: ""
  property string keyboardVariant: ""
  property real fontScale: 1.0
  property bool loaded: false
  property bool migrated: false

  readonly property string timeFormat: (clock24h ? "HH:mm" : "h:mm") + (showSeconds ? ":ss" : "") + (clock24h ? "" : " AP")

  function save() {
    if (!loaded) return
    file.setText(JSON.stringify({ clock24h: clock24h, showSeconds: showSeconds, dateFormat: dateFormat, dnd: dnd, wallpaper: wallpaper, wallpaperFit: wallpaperFit, wallpaperDir: wallpaperDir, colors: colors, fontFamily: fontFamily, fontScale: fontScale, keyboardLayout: keyboardLayout, keyboardVariant: keyboardVariant, screenshotDir: screenshotDir, screenshotCopy: screenshotCopy, screenshotEdit: screenshotEdit, colorsVersion: colorsVersion }, null, 2))
  }

  onClock24hChanged: save()
  onShowSecondsChanged: save()
  onDateFormatChanged: save()
  onDndChanged: save()
  onWallpaperChanged: save()
  onWallpaperFitChanged: save()
  onWallpaperDirChanged: save()
  onColorsChanged: save()
  onFontFamilyChanged: save()
  onFontScaleChanged: save()
  onScreenshotDirChanged: save()
  onScreenshotCopyChanged: save()
  onScreenshotEditChanged: save()
  onKeyboardLayoutChanged: save()
  onKeyboardVariantChanged: save()

  // Saved color picks carry a version. Each step upgrades picks written by an older one.
  readonly property int colorsVersion: 4

  // Before the token split (files without a version): each old id fed several tokens
  readonly property var splitIds: ({
    fg: ["textBody", "textInput", "iconBody", "knob"],
    muted: ["textHint", "iconDim", "lineDivider"],
    accent: ["textSelected", "iconActive", "fillHighlight", "lineFocus"],
    bg: ["fillWindow", "textOnHighlight", "knobActive"],
    surface: ["fillCard"],
    hover: ["fillHover"],
    bright: ["textTitle", "fillMarker"],
    danger: ["textError", "iconAlert", "fillDanger"],
    warning: ["textWarning", "fillWarning"],
    success: ["textSuccess"],
    titleActive: ["titlebarActive"],
    titleInactive: ["titlebarInactive"],
    titleText: ["titlebarText"]
  })

  // Version 4: one token for selected, danger, warning and success; the knobs follow the text colors
  readonly property var mergedIds: ({
    selected: ["textSelected", "iconActive", "lineFocus"],
    danger: ["textError", "iconAlert", "fillDanger"],
    warning: ["textWarning", "fillWarning"],
    success: ["textSuccess"]
  })

  function migrateColors(map, from) {
    let picks = map
    if (from < 1 && Object.keys(picks).some(k => splitIds[k])) {
      const out = {}
      for (const key in picks) {
        if (splitIds[key]) { for (const id of splitIds[key]) if (!(id in picks)) out[id] = picks[key] }
        else out[key] = picks[key]
      }
      picks = out
    }
    if (from < 2) {
      // fillHighlight became fillPrimary and fillMarker became fillHighlight; textOnHighlight was split
      const out = {}
      for (const key in picks) {
        if (key === "fillHighlight") out.fillPrimary = picks[key]
        else if (key === "fillMarker") out.fillHighlight = picks[key]
        else if (key === "textOnHighlight") { out.textPrimary = picks[key]; out.textHighlight = picks[key] }
        else out[key] = picks[key]
      }
      picks = out
    }
    if (from < 3) {
      // fillHighlight and textHighlight were removed
      const out = {}
      for (const key in picks) if (key !== "fillHighlight" && key !== "textHighlight") out[key] = picks[key]
      picks = out
    }
    if (from < 4) {
      const out = {}
      const taken = {}
      for (const target in mergedIds) {
        for (const id of mergedIds[target]) {
          taken[id] = true
          if (out[target] === undefined && picks[id] !== undefined) out[target] = picks[id]
        }
      }
      for (const key in picks) if (!taken[key] && key !== "knob" && key !== "knobActive") out[key] = picks[key]
      picks = out
    }
    return picks
  }

  function setColor(id, slot) {
    const next = Object.assign({}, colors)
    if (slot) next[id] = slot; else delete next[id]
    colors = next
  }

  FileView {
    id: file
    path: Quickshell.env("QS_PREFS") || (Quickshell.env("HOME") + "/.config/quickshell/prefs.json")
    atomicWrites: true
    onLoaded: {
      try {
        const data = JSON.parse(text())
        if (data.clock24h !== undefined) root.clock24h = data.clock24h
        if (data.showSeconds !== undefined) root.showSeconds = data.showSeconds
        if (data.dateFormat) root.dateFormat = data.dateFormat
        if (data.dnd !== undefined) root.dnd = data.dnd
        if (data.wallpaper !== undefined) root.wallpaper = data.wallpaper
        if (data.wallpaperFit) root.wallpaperFit = data.wallpaperFit
        if (data.wallpaperDir) root.wallpaperDir = data.wallpaperDir
        if (data.colors && typeof data.colors === "object") {
          const from = data.colorsVersion || 0
          const picks = root.migrateColors(data.colors, from)
          if (from < root.colorsVersion) root.migrated = true
          root.colors = picks
        }
        if (typeof data.fontFamily === "string") root.fontFamily = data.fontFamily
        if (data.fontScale > 0) root.fontScale = data.fontScale
        if (data.screenshotDir) root.screenshotDir = data.screenshotDir
        if (data.screenshotCopy !== undefined) root.screenshotCopy = data.screenshotCopy
        if (data.screenshotEdit !== undefined) root.screenshotEdit = data.screenshotEdit
        if (typeof data.keyboardLayout === "string") root.keyboardLayout = data.keyboardLayout
        if (typeof data.keyboardVariant === "string") root.keyboardVariant = data.keyboardVariant
      } catch (e) {}
      root.loaded = true
      if (root.migrated) root.save()
    }
    onLoadFailed: root.loaded = true
  }
}
