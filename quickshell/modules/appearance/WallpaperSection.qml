import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  Layout.fillWidth: true
  spacing: Theme.spaceMd

  property var images: []

  readonly property var fits: [
    { label: "Fill (crop to the screen)", value: "fill" },
    { label: "Fit (whole picture)", value: "fit" },
    { label: "Stretch", value: "stretch" },
    { label: "Center", value: "center" }
  ]

  function scan() {
    findCmd.run(["find", Prefs.wallpaperDir, "-maxdepth", "2", "-type", "f",
      "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"])
  }

  Component.onCompleted: scan()

  Cmd {
    id: findCmd
    onFinished: (code, out, err) => root.images = out.split("\n").filter(l => l !== "").sort()
  }

  SectionHeader { text: "WALLPAPER" }

  FormRow {
    label: "Current"
    Label {
      Layout.fillWidth: true
      text: Prefs.wallpaper !== "" ? Prefs.wallpaper : "None (solid colour)"
      elide: Text.ElideMiddle
    }
  }

  FormRow {
    label: "Picture fit"
    Dropdown { Layout.fillWidth: true; value: Prefs.wallpaperFit; options: root.fits; onPicked: v => Prefs.wallpaperFit = v }
  }

  FormRow {
    label: "Pictures folder"
    hint: "Images up to two levels deep. Press Enter to rescan."
    TextField {
      Layout.fillWidth: true
      text: Prefs.wallpaperDir
      onAccepted: { Prefs.wallpaperDir = text; root.scan() }
    }
  }

  RowLayout {
    spacing: Theme.spaceMd
    ActionButton { text: "Rescan"; onActivated: root.scan() }
    ActionButton { text: "No wallpaper"; enabled: Prefs.wallpaper !== ""; onActivated: Prefs.wallpaper = "" }
  }

  Label {
    visible: root.images.length === 0
    text: "No images in this folder."
    color: Theme.muted
  }

  Flow {
    Layout.fillWidth: true
    spacing: Theme.spaceMd

    Repeater {
      model: root.images
      delegate: Clickable {
        required property string modelData
        width: Theme.thumbWidth
        height: Theme.thumbHeight
        idleColor: Theme.surface
        onActivated: Prefs.wallpaper = modelData

        Image {
          anchors.fill: parent
          source: "file://" + modelData
          sourceSize.width: Theme.thumbWidth
          sourceSize.height: Theme.thumbHeight
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          cache: false
        }

        Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.width: 2
          border.color: Theme.accent
          visible: modelData === Prefs.wallpaper
        }
      }
    }
  }
}
