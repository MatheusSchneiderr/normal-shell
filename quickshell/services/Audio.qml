pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs
import qs.services

Scope {
  id: root
  property var unplugged: []
  property bool ready: false
  property var cards: []
  property var serials: ({})
  property bool pactl: false

  PwObjectTracker { objects: Pipewire.nodes.values }

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
  readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
  readonly property string icon: muted ? Icons.volumeMute : (volume < 0.34 ? Icons.volumeLow : Icons.volumeHigh)

  function toggleMute() { if (sink && sink.audio) sink.audio.muted = !sink.audio.muted }
  function nudge(delta) { if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta)) }

  PwObjectTracker { objects: [root.sink] }

  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio && ready && usable(n))
  readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio && /_input\./.test(n.name) && ready && usable(n))
  readonly property var streams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream && n.audio)

  function usable(n) {
    if (n === Pipewire.defaultAudioSink || n === Pipewire.defaultAudioSource) return true
    const text = n.description || ""
    for (let i = 0; i < unplugged.length; i++) if (text.indexOf(unplugged[i]) >= 0) return false
    return true
  }

  function hold() { poll.hold() }
  function release() { poll.release() }

  function label(n) { return n ? (n.nickname || n.description || n.name) : "" }
  function percent(v) { return Math.round(v * 100) + "%" }
  function options(nodes) { return nodes.map(n => ({ label: label(n), value: n })) }

  function refresh() {
    routes.run()
    if (pactl) { cardProc.run(); inputProc.run() }
  }

  function setProfile(card, profile) { Quickshell.execDetached(["pactl", "set-card-profile", card, profile]); settle.restart() }
  function moveStream(node, sink) {
    const index = serials[node.properties["object.serial"]]
    if (index !== undefined) Quickshell.execDetached(["pactl", "move-sink-input", String(index), sink.name])
  }
  function setBalance(node, balance) {
    const volume = node.audio.volume
    const left = Math.round(volume * 100 * Math.min(1, 1 - balance))
    const right = Math.round(volume * 100 * Math.min(1, 1 + balance))
    Quickshell.execDetached(["pactl", "set-sink-volume", node.name, left + "%", right + "%"])
  }

  Cmd {
    command: ["sh", "-c", "command -v pactl"]
    Component.onCompleted: run()
    onFinished: (code) => root.pactl = code === 0
  }

  Timer { id: settle; interval: 600; onTriggered: root.refresh() }

  Poller { id: poll; interval: 2000; onTick: root.refresh() }

  Cmd {
    id: routes
    command: ["pw-dump"]
    onFinished: (code, text) => {
      try {
        const found = []
        for (const obj of JSON.parse(text)) {
          if (obj.type !== "PipeWire:Interface:Device") continue
          const list = (obj.info.params || {}).EnumRoute || []
          for (const route of list) if (route.available === "no") found.push(route.description)
        }
        root.unplugged = found
      } catch (e) {}
      root.ready = true
    }
  }

  Cmd {
    id: cardProc
    command: ["pactl", "-f", "json", "list", "cards"]
    onFinished: (code, text) => {
      try {
        root.cards = JSON.parse(text).map(c => ({
          name: c.name,
          title: (c.properties || {})["device.description"] || c.name,
          active: c.active_profile,
          profiles: Object.keys(c.profiles).filter(k => c.profiles[k].available !== false).map(k => ({ label: c.profiles[k].description, value: k }))
        }))
      } catch (e) {}
    }
  }

  Cmd {
    id: inputProc
    command: ["pactl", "-f", "json", "list", "sink-inputs"]
    onFinished: (code, text) => {
      try {
        const map = {}
        for (const input of JSON.parse(text)) map[input.properties["object.serial"]] = input.index
        root.serials = map
      } catch (e) {}
    }
  }
}
