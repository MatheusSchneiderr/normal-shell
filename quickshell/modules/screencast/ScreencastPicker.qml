import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.components
import qs.services

Scope {
  id: root
  property bool open: false
  property var items: []
  property string replyPath: ""

  function finish(choice) {
    if (!open) return
    open = false
    const write = choice === "" ? ": > \"$2\"" : "printf '%s\\n' \"$1\" > \"$2\""
    Quickshell.execDetached(["sh", "-c", write, "sh", choice, replyPath])
  }

  IpcHandler {
    target: "picker"
    function ask(itemsPath: string, replyFile: string): void {
      root.replyPath = replyFile
      load.run(["cat", itemsPath])
    }
    function cancel(): void { root.finish("") }
  }

  Cmd {
    id: load
    onFinished: (code, text) => {
      root.items = text.split("\n").map(l => l.trim()).filter(l => l !== "")
      root.open = root.items.length > 0
      if (!root.open) Quickshell.execDetached(["sh", "-c", ": > \"$1\"", "sh", root.replyPath])
    }
  }

  LazyLoader {
    active: root.open

    PanelWindow {
      id: window
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      function step(forward) {
        const item = keys.Window.window ? keys.Window.window.activeFocusItem : null
        const next = item ? item.nextItemInFocusChain(forward) : null
        if (next) next.forceActiveFocus(forward ? Qt.TabFocusReason : Qt.BacktabFocusReason)
      }

      Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.finish("")
        Keys.onDownPressed: window.step(true)
        Keys.onUpPressed: window.step(false)
        Timer {
          interval: 80
          running: true
          onTriggered: {
            const item = keys.Window.window ? keys.Window.window.activeFocusItem : null
            if (!item || item === keys) window.step(true)
          }
        }

        MouseArea { anchors.fill: parent; onClicked: root.finish("") }

        Rectangle {
          anchors.centerIn: parent
          width: Theme.popupWidth + Theme.spaceLg * 2
          height: column.implicitHeight + Theme.popupPadding * 2
          color: Theme.bg

          MouseArea { anchors.fill: parent }

          ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.spaceSm

            SectionHeader { text: "SHARE WHICH SCREEN?" }

            Repeater {
              model: root.items
              delegate: ListRow {
                required property string modelData
                glyph: Icons.monitor
                title: modelData
                onClicked: root.finish(modelData)
              }
            }

            Label { text: "Enter to share, Esc to cancel"; color: Theme.muted; font.pixelSize: Theme.fontSmall }
          }
        }
      }
    }
  }
}
