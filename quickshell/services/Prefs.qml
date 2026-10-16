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
  property string keyboardLayout: ""
  property string keyboardVariant: ""
  property real fontScale: 1.0
  property bool loaded: false

  readonly property string timeFormat: (clock24h ? "HH:mm" : "h:mm") + (showSeconds ? ":ss" : "") + (clock24h ? "" : " AP")

  function save() {
    if (!loaded) return
    file.setText(JSON.stringify({ clock24h: clock24h, showSeconds: showSeconds, dateFormat: dateFormat, dnd: dnd, wallpaper: wallpaper, wallpaperFit: wallpaperFit, wallpaperDir: wallpaperDir, colors: colors, fontFamily: fontFamily, fontScale: fontScale, keyboardLayout: keyboardLayout, keyboardVariant: keyboardVariant }, null, 2))
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
  onKeyboardLayoutChanged: save()
  onKeyboardVariantChanged: save()

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
        if (data.colors && typeof data.colors === "object") root.colors = data.colors
        if (typeof data.fontFamily === "string") root.fontFamily = data.fontFamily
        if (data.fontScale > 0) root.fontScale = data.fontScale
        if (typeof data.keyboardLayout === "string") root.keyboardLayout = data.keyboardLayout
        if (typeof data.keyboardVariant === "string") root.keyboardVariant = data.keyboardVariant
      } catch (e) {}
      root.loaded = true
    }
    onLoadFailed: root.loaded = true
  }
}
