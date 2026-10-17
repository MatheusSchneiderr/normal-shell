import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
  id: host
  property string current: ""
  signal closeRequested()

  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  function focusedItem() {
    const win = keys.Window.window
    return win ? win.activeFocusItem : null
  }

  function step(forward) {
    const focused = focusedItem()
    const next = focused ? focused.nextItemInFocusChain(forward) : null
    if (next) next.forceActiveFocus(forward ? Qt.TabFocusReason : Qt.BacktabFocusReason)
  }

  Timer {
    id: initialFocus
    interval: 60
    onTriggered: {
      const focused = host.focusedItem()
      if (focused === null || focused === keys) host.step(true)
    }
  }

  Item {
    id: keys
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: host.closeRequested()
    Keys.onDownPressed: host.step(true)
    Keys.onUpPressed: host.step(false)

    MouseArea { anchors.fill: parent; onClicked: host.closeRequested() }

    Rectangle {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.rightMargin: Theme.spaceMd
      anchors.bottomMargin: Theme.barHeight
      width: Theme.popupWidth
      height: body.item ? body.item.implicitHeight + Theme.popupPadding * 2 : 60
      color: Theme.fillWindow
      visible: body.item !== null && body.item.ready !== false

      MouseArea { anchors.fill: parent }

      Loader {
        id: body
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        source: host.current !== "" ? "../modules/" + host.current + "/" + host.current.charAt(0).toUpperCase() + host.current.slice(1) + "Popup.qml" : ""
        onLoaded: initialFocus.restart()
      }
    }
  }
}
