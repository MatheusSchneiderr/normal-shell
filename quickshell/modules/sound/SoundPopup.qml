import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs
import qs.components

ColumnLayout {
  id: root
  spacing: Theme.spaceMd

  readonly property var source: Pipewire.defaultAudioSource

  Component.onCompleted: Audio.hold()
  Component.onDestruction: Audio.release()

  component NodeSlider: SliderRow {
    required property var node
    property string iconOn: Icons.volumeHigh
    property string iconMuted: Icons.volumeMute
    glyph: node.audio.muted ? iconMuted : iconOn
    glyphColor: node.audio.muted ? Theme.danger : Theme.iconBody
    value: node.audio.volume
    valueText: Audio.percent(node.audio.volume)
    onGlyphClicked: node.audio.muted = !node.audio.muted
    onMoved: v => node.audio.volume = v
  }

  SectionHeader { text: "OUTPUT" }
  NodeSlider { visible: Audio.sink !== null; node: Audio.sink }

  Repeater {
    model: Audio.sinks
    delegate: DeviceRow {
      required property var modelData
      text: Audio.label(modelData)
      current: modelData === Audio.sink
      onActivated: Pipewire.preferredDefaultAudioSink = modelData
    }
  }

  SectionHeader { text: "INPUT"; visible: root.source !== null }
  NodeSlider { visible: root.source !== null; node: root.source; iconOn: Icons.mic; iconMuted: Icons.micOff }

  Repeater {
    model: Audio.sources
    delegate: DeviceRow {
      required property var modelData
      text: Audio.label(modelData)
      current: modelData === root.source
      onActivated: Pipewire.preferredDefaultAudioSource = modelData
    }
  }

  SectionHeader { text: "APPLICATIONS"; visible: Audio.streams.length > 0 }
  Repeater {
    model: Audio.streams
    delegate: ColumnLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: 0
      Label { text: modelData.properties["application.name"] || Audio.label(modelData) }
      NodeSlider { node: modelData }
    }
  }
}
