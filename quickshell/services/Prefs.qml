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
  property bool loaded: false

  readonly property string timeFormat: (clock24h ? "HH:mm" : "h:mm") + (showSeconds ? ":ss" : "") + (clock24h ? "" : " AP")

  function save() {
    if (!loaded) return
    file.setText(JSON.stringify({ clock24h: clock24h, showSeconds: showSeconds, dateFormat: dateFormat, dnd: dnd }, null, 2))
  }

  onClock24hChanged: save()
  onShowSecondsChanged: save()
  onDateFormatChanged: save()
  onDndChanged: save()

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
      } catch (e) {}
      root.loaded = true
    }
    onLoadFailed: root.loaded = true
  }
}
