import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs
import qs.components

SettingsPage {
  id: root
  title: "Sound"

  Component.onCompleted: Audio.hold()
  Component.onDestruction: Audio.release()

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource
  readonly property string testSound: "/run/current-system/sw/share/sounds/freedesktop/stereo/audio-test-signal.oga"

  function balanceOf(node) {
    const ch = node && node.audio ? node.audio.volumes : []
    if (!ch || ch.length < 2) return 0
    const left = ch[0], right = ch[1]
    const top = Math.max(left, right)
    return top <= 0 ? 0 : (right - left) / top
  }

  PwObjectTracker { objects: [root.sink, root.source] }

  SectionHeader { text: "OUTPUT" }
  Label { visible: !root.sink; text: "No output device"; color: Theme.muted }

  FormRow {
    visible: root.sink !== null
    label: "Device"
    Dropdown {
      Layout.fillWidth: true
      value: root.sink
      options: Audio.options(Audio.sinks)
      onPicked: v => Pipewire.preferredDefaultAudioSink = v
    }
  }
  FormRow {
    visible: root.sink !== null
    label: "Volume"
    hint: root.sink && root.sink.audio ? Audio.percent(root.sink.audio.volume) : ""
    Slider {
      Layout.fillWidth: true
      value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
      maximum: 1.0
      onMoved: v => root.sink.audio.volume = v
    }
    ActionButton {
      text: root.sink && root.sink.audio && root.sink.audio.muted ? "Unmute" : "Mute"
      danger: root.sink && root.sink.audio && root.sink.audio.muted
      onActivated: root.sink.audio.muted = !root.sink.audio.muted
    }
  }
  FormRow {
    visible: root.sink !== null && Audio.pactl
    label: "Balance"
    hint: "Left / right"
    Slider {
      Layout.fillWidth: true
      value: (root.balanceOf(root.sink) + 1) / 2
      maximum: 1.0
      steps: 20
      onMoved: v => Audio.setBalance(root.sink, Math.abs(v - 0.5) < 0.03 ? 0 : v * 2 - 1)
    }
    ActionButton { text: "Center"; onActivated: Audio.setBalance(root.sink, 0) }
  }
  FormRow {
    visible: root.sink !== null
    label: "Test"
    hint: "Plays a short signal on the selected device"
    ActionButton {
      text: "Play test sound"
      onActivated: Quickshell.execDetached(["pw-play", "--target", String(root.sink.id), root.testSound])
    }
  }

  SectionHeader { text: "INPUT" }
  Label { visible: !root.source; text: "No input device"; color: Theme.muted }

  FormRow {
    visible: root.source !== null
    label: "Device"
    Dropdown {
      Layout.fillWidth: true
      value: root.source
      options: Audio.options(Audio.sources)
      onPicked: v => Pipewire.preferredDefaultAudioSource = v
    }
  }
  FormRow {
    visible: root.source !== null
    label: "Volume"
    hint: root.source && root.source.audio ? Audio.percent(root.source.audio.volume) : ""
    Slider {
      Layout.fillWidth: true
      value: root.source && root.source.audio ? root.source.audio.volume : 0
      maximum: 1.0
      onMoved: v => root.source.audio.volume = v
    }
    ActionButton {
      text: root.source && root.source.audio && root.source.audio.muted ? "Unmute" : "Mute"
      danger: root.source && root.source.audio && root.source.audio.muted
      onActivated: root.source.audio.muted = !root.source.audio.muted
    }
  }

  SectionHeader { text: "DEVICE PROFILES"; visible: Audio.cards.length > 0 }
  Repeater {
    model: Audio.cards
    delegate: FormRow {
      required property var modelData
      label: modelData.title
      hint: "Profile of the whole sound card"
      Dropdown {
        Layout.fillWidth: true
        value: modelData.active
        options: modelData.profiles
        onPicked: v => Audio.setProfile(modelData.name, v)
      }
    }
  }
  Label {
    visible: !Audio.pactl
    text: "Profiles, balance and moving apps need pactl (package pulseaudio) which is not installed."
    color: Theme.warning
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }

  SectionHeader { text: "APPLICATIONS"; visible: Audio.streams.length > 0 }
  Repeater {
    model: Audio.streams
    delegate: ColumnLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: Theme.spaceXs
      PwObjectTracker { objects: [modelData] }
      Label { text: modelData.properties["application.name"] || Audio.label(modelData); color: Theme.bright }
      RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceMd
        Slider {
          Layout.fillWidth: true
          value: modelData.audio.volume
          maximum: 1.0
          onMoved: v => modelData.audio.volume = v
        }
        Label { text: Audio.percent(modelData.audio.volume); Layout.preferredWidth: Theme.valueWidth; horizontalAlignment: Text.AlignRight }
        ActionButton { text: modelData.audio.muted ? "Unmute" : "Mute"; onActivated: modelData.audio.muted = !modelData.audio.muted }
      }
      Dropdown {
        visible: Audio.pactl
        Layout.preferredWidth: Theme.fieldXl
        value: root.sink
        options: Audio.options(Audio.sinks)
        onPicked: v => Audio.moveStream(modelData, v)
      }
    }
  }
}
