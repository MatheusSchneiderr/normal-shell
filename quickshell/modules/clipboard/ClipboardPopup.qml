import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  spacing: Theme.spaceSm

  property var entries: []
  property string lastList: ""
  property string query: ""
  property bool confirmClear: false
  readonly property var shown: entries.filter(e => query === "" || e.text.toLowerCase().indexOf(query.toLowerCase()) >= 0).slice(0, 60)

  function copy(entry) {
    Quickshell.execDetached(["sh", "-c", "cliphist decode " + entry.id + " | wl-copy"])
    Ui.popup = ""
  }

  Component.onCompleted: search.forceActiveFocus()

  Cmd {
    id: lister
    command: ["cliphist", "list"]
    onFinished: (code, text) => {
      if (text === root.lastList) return
      root.lastList = text
      const out = []
      for (const line of text.split("\n")) {
        const tab = line.indexOf("\t")
        if (tab < 0) continue
        let preview = line.slice(tab + 1)
        const image = /^\[\[ binary data /.test(preview)
        if (image) preview = "Image  " + preview.replace(/^\[\[ binary data /, "").replace(/ \]\]$/, "")
        out.push({ id: line.slice(0, tab), text: preview, image: image })
      }
      root.entries = out
    }
  }

  Timer {
    interval: 1500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: lister.run()
  }

  Timer {
    id: confirmReset
    interval: 3000
    onTriggered: root.confirmClear = false
  }

  SectionHeader { text: "CLIPBOARD" }

  TextField {
    id: search
    Layout.fillWidth: true
    placeholder: "Search clipboard..."
    onTextChanged: root.query = text
    onAccepted: if (root.shown.length > 0) root.copy(root.shown[0])
  }

  ListView {
    id: list
    Layout.fillWidth: true
    Layout.preferredHeight: Math.min(Math.max(contentHeight, 40), 360)
    clip: true
    model: root.shown
    delegate: Clickable {
      required property var modelData
      required property int index
      width: list.width
      height: Theme.rowHeight
      onActivated: root.copy(modelData)
      onActiveFocusChanged: if (activeFocus) list.positionViewAtIndex(index, ListView.Contain)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spaceSm
        anchors.rightMargin: Theme.spaceSm
        spacing: Theme.spaceMd
        Glyph { text: modelData.image ? Icons.image : Icons.paste; color: Theme.accent }
        Label { Layout.fillWidth: true; text: modelData.text; elide: Text.ElideRight }
      }
    }
  }

  Label {
    visible: root.shown.length === 0
    text: root.entries.length === 0 ? "Clipboard history is empty" : "No matches"
    color: Theme.muted
    font.pixelSize: Theme.fontBody
    Layout.leftMargin: Theme.spaceSm
  }

  ListRow {
    visible: root.entries.length > 0
    glyph: Icons.trash
    title: root.confirmClear ? "Click again to clear all history" : "Clear history"
    selected: root.confirmClear
    onClicked: {
      if (root.confirmClear) {
        Quickshell.execDetached(["cliphist", "wipe"])
        root.entries = []
        root.confirmClear = false
      } else {
        root.confirmClear = true
        confirmReset.restart()
      }
    }
  }
}
