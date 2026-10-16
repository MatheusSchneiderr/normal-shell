import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

Scope {
  id: root

  // One decode size for every screen, so all windows share a single cached copy of the picture
  readonly property int decodeWidth: Math.max(...Quickshell.screens.map(s => Math.round(s.width * s.devicePixelRatio)), 1)

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window
      required property var modelData
      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      color: Theme.bg
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "wallpaper"

      readonly property var fits: ({
        fill: Image.PreserveAspectCrop,
        fit: Image.PreserveAspectFit,
        stretch: Image.Stretch,
        center: Image.Pad
      })

      Image {
        anchors.fill: parent
        visible: Prefs.wallpaper !== ""
        source: Prefs.wallpaper !== "" ? "file://" + Prefs.wallpaper : ""
        fillMode: window.fits[Prefs.wallpaperFit] ?? Image.PreserveAspectCrop
        sourceSize.width: root.decodeWidth
        asynchronous: true
      }
    }
  }
}
