import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.components

PanelWindow {
  id: menu
  property bool open: false
  signal closeRequested()

  visible: open
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  property string pending: ""
  property int countdown: 30

  signal settingsRequested()

  readonly property var actions: [
    { id: "sleep", icon: Icons.moon, label: "Sleep", confirm: false, cmd: ["systemctl", "suspend"] },
    { id: "restart", icon: Icons.restart, label: "Restart", confirm: true, cmd: ["systemctl", "reboot"] },
    { id: "shutdown", icon: Icons.power, label: "Shut Down", confirm: true, cmd: ["systemctl", "poweroff"] },
    { id: "lock", icon: Icons.lock, label: "Lock", confirm: false, cmd: ["quickshell", "-c", "panel", "ipc", "call", "lock", "lock"] },
    { id: "logout", icon: Icons.signOut, label: "Log Out", confirm: true, cmd: ["sh", "-c", "loginctl terminate-session $XDG_SESSION_ID"] }
  ]

  // QS_DRYRUN=1 (dev/smoke.sh) turns every power action into a no-op
  readonly property bool dryRun: Quickshell.env("QS_DRYRUN") === "1"

  function run(action) {
    Quickshell.execDetached(dryRun ? ["true"] : action.cmd)
    pending = ""
    menu.closeRequested()
  }

  function choose(action) {
    if (action.confirm) { pending = action.id; countdown = 30 }
    else run(action)
  }

  function pendingAction() {
    for (let i = 0; i < actions.length; i++) if (actions[i].id === pending) return actions[i]
    return null
  }

  onOpenChanged: {
    pending = ""
    if (open) apps.reset()
  }

  onPendingChanged: if (pending !== "") Qt.callLater(() => confirm.focusConfirm())

  Timer {
    interval: 1000
    repeat: true
    running: menu.pending !== ""
    onTriggered: {
      menu.countdown -= 1
      if (menu.countdown <= 0) menu.run(menu.pendingAction())
    }
  }

  MouseArea { anchors.fill: parent; onClicked: menu.closeRequested() }

  Rectangle {
    x: 0
    y: parent.height - height - Theme.barHeight
    width: Theme.startMenuWidth
    height: Theme.startMenuHeight
    color: Theme.bg

    Keys.onEscapePressed: { if (menu.pending !== "") menu.pending = ""; else menu.closeRequested() }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Theme.spaceMd
      spacing: Theme.spaceMd

      AppList {
        id: apps
        Layout.fillWidth: true
        Layout.fillHeight: true
        onLaunched: menu.closeRequested()
        onSettingsRequested: { menu.closeRequested(); menu.settingsRequested() }
      }

      Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.muted }

      PowerRow {
        actions: menu.actions
        onChosen: action => menu.choose(action)
        onSearchRequested: apps.focusSearch()
      }
    }

    ConfirmOverlay {
      id: confirm
      anchors.fill: parent
      visible: menu.pending !== ""
      title: menu.pendingAction() ? menu.pendingAction().label + "?" : ""
      countdown: menu.countdown
      onConfirmed: menu.run(menu.pendingAction())
      onCancelled: menu.pending = ""
    }
  }
}
