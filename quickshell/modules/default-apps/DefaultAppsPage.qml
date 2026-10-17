import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.components

SettingsPage {
  id: root
  title: "Default applications"

  readonly property string script: Quickshell.shellPath("modules/default-apps/mime-apps.lua")
  property var apps: []
  property var defaults: ({})
  property bool loaded: false
  property string filter: ""

  readonly property var slots: [
    { label: "Web browser", icon: Icons.globe, mimes: ["x-scheme-handler/http", "x-scheme-handler/https", "text/html", "application/xhtml+xml"] },
    { label: "File manager", icon: Icons.folder, mimes: ["inode/directory"] },
    { label: "Email", icon: Icons.mail, mimes: ["x-scheme-handler/mailto"] },
    { label: "PDF documents", icon: Icons.pdf, mimes: ["application/pdf"] },
    { label: "Images", icon: Icons.image, mimes: ["image/png", "image/jpeg", "image/gif", "image/webp", "image/svg+xml"] },
    { label: "Video", icon: Icons.video, mimes: ["video/mp4", "video/x-matroska", "video/webm"] },
    { label: "Music", icon: Icons.music, mimes: ["audio/mpeg", "audio/flac", "audio/ogg", "audio/x-wav"] },
    { label: "Text files", icon: Icons.textFile, mimes: ["text/plain", "text/markdown"] }
  ]

  readonly property var allMimes: {
    const set = {}
    for (const a of apps) for (const m of a.mimes) set[m] = true
    return Object.keys(set).sort()
  }
  readonly property var shownMimes: {
    const f = filter.toLowerCase()
    return allMimes.filter(m => f === "" || m.toLowerCase().indexOf(f) >= 0).slice(0, 40)
  }

  function candidates(mimes) {
    const primary = mimes[0]
    return apps.filter(a => a.mimes.indexOf(primary) >= 0).map(a => ({ label: a.name, value: a.id }))
  }

  function candidatesFor(mime) {
    return apps.filter(a => a.mimes.indexOf(mime) >= 0).map(a => ({ label: a.name, value: a.id }))
  }

  function nameOf(id) {
    const app = apps.find(a => a.id === id)
    return app ? app.name : (id || "None")
  }

  function choose(id, mimes) {
    const app = apps.find(a => a.id === id)
    const supported = app ? mimes.filter((m, i) => i === 0 || app.mimes.indexOf(m) >= 0) : mimes
    const copy = Object.assign({}, defaults)
    for (const m of supported) copy[m] = id
    defaults = copy
    Quickshell.execDetached(["lua", script, "set", id].concat(supported))
  }

  function load() {
    const mimes = []
    for (const s of slots) for (const m of s.mimes) mimes.push(m)
    stateProc.run(["lua", script, "state"].concat(mimes))
  }

  Component.onCompleted: load()

  Cmd {
    id: stateProc
    onFinished: (code, text) => {
      try {
        const data = JSON.parse(text)
        root.apps = data.apps
        root.defaults = data.defaults
        root.loaded = true
      } catch (e) {}
    }
  }

  Label {
    text: "Choose which application opens each kind of file or link. Changes apply immediately."
    color: Theme.textHint
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }
  Label { visible: !root.loaded; text: "Loading..."; color: Theme.textHint }

  SectionHeader { text: "COMMON"; visible: root.loaded }
  Repeater {
    model: root.loaded ? root.slots : []
    delegate: FormRow {
      required property var modelData
      label: modelData.label
      Dropdown {
        Layout.fillWidth: true
        value: root.defaults[modelData.mimes[0]]
        options: root.candidates(modelData.mimes)
        onPicked: v => root.choose(v, modelData.mimes)
      }
    }
  }

  SectionHeader { text: "ALL FILE TYPES"; visible: root.loaded }
  FormRow {
    visible: root.loaded
    label: "Search"
    hint: "Type part of a file type, e.g. pdf or image/"
    TextField { Layout.fillWidth: true; placeholder: "File type"; onTextChanged: root.filter = text }
  }
  Repeater {
    model: root.loaded ? root.shownMimes : []
    delegate: FormRow {
      required property string modelData
      label: modelData
      Dropdown {
        Layout.fillWidth: true
        value: root.defaults[modelData]
        options: root.candidatesFor(modelData)
        onPicked: v => root.choose(v, [modelData])
      }
    }
  }
  Label {
    visible: root.loaded && root.allMimes.length > root.shownMimes.length
    text: "Showing the first " + root.shownMimes.length + " of " + root.allMimes.length + " types. Use the search to narrow it down."
    color: Theme.textHint
  }
}
