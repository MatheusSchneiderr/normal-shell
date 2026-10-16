import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  Layout.fillWidth: true
  spacing: Theme.spaceMd

  property bool pending: false
  property int countdown: 10
  property var before: ({})

  readonly property var slotOptions: Theme.slots.map(s => ({ label: s.id + "  " + s.label, value: s.id, swatch: Theme.slotColor(s.id) }))

  readonly property var groups: {
    const out = []
    for (const c of Theme.classes) {
      let group = out.find(g => g.name === c.group)
      if (!group) { group = { name: c.group, items: [] }; out.push(group) }
      group.items.push(c)
    }
    return out
  }

  function change(apply) {
    if (!pending) { before = Object.assign({}, Prefs.colors); countdown = 10; pending = true }
    apply()
  }

  function keep() { pending = false }
  function revert() { Prefs.colors = before; pending = false }

  Timer {
    interval: 1000
    repeat: true
    running: root.pending
    onTriggered: { root.countdown -= 1; if (root.countdown <= 0) root.revert() }
  }

  SectionHeader { text: "COLORS" }
  Label {
    text: "Pick which palette color each part of the desktop uses. The palette comes from your theme."
    color: Theme.muted
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }

  Rectangle {
    visible: root.pending
    Layout.fillWidth: true
    Layout.preferredHeight: Theme.buttonHeight
    color: Theme.surface
    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: Theme.spaceMd
      anchors.rightMargin: Theme.spaceMd
      spacing: Theme.spaceMd
      Label { Layout.fillWidth: true; text: "Keep these colors? Reverting in " + root.countdown + " s" }
      ActionButton { text: "Keep"; primary: true; onActivated: root.keep() }
      ActionButton { text: "Revert"; onActivated: root.revert() }
    }
  }

  Repeater {
    model: root.groups
    delegate: ColumnLayout {
      required property var modelData
      Layout.fillWidth: true
      spacing: Theme.spaceMd

      SectionHeader { text: modelData.name.toUpperCase() }

      Repeater {
        model: modelData.items
        delegate: FormRow {
          required property var modelData
          label: modelData.label
          hint: modelData.hint
          Dropdown {
            Layout.fillWidth: true
            options: root.slotOptions
            value: Prefs.colors[modelData.id] ?? modelData.slot
            onPicked: slot => root.change(() => Prefs.setColor(modelData.id, slot === modelData.slot ? "" : slot))
          }
        }
      }
    }
  }

  RowLayout {
    ActionButton { text: "Reset all colors"; onActivated: root.change(() => Prefs.colors = ({})) }
  }
}
