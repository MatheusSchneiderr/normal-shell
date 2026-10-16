import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Services.UPower
import qs
import qs.components
import qs.services

Scope {
  id: root
  readonly property string runtime: Quickshell.env("XDG_RUNTIME_DIR")
  readonly property string shot: runtime + "/quickshell-lock.png"
  readonly property string user: Quickshell.env("USER")
  property bool locked: false
  property bool shotReady: false
  property string password: ""
  property string message: ""
  property bool checking: false
  property int attempt: 0

  function lock() {
    if (root.locked) return
    capture.run()
  }

  function submit(text) {
    if (checking || text === "") return
    password = text
    message = ""
    checking = true
    pam.start()
  }

  function finish() {
    root.locked = false
    checking = false
    message = ""
    password = ""
    Quickshell.execDetached(["rm", "-f", shot])
  }

  IpcHandler {
    target: "lock"
    function lock(): void { root.lock() }
    function locked(): bool { return root.locked }
  }

  Cmd {
    id: capture
    command: ["grim", root.shot]
    onFinished: (code) => { root.shotReady = code === 0; root.locked = true }
  }

  PamContext {
    id: pam
    config: Quickshell.env("QS_LOCK_PAM") || "swaylock"
    configDirectory: Quickshell.env("QS_LOCK_PAMDIR") || "/etc/pam.d"
    user: root.user

    onPamMessage: {
      if (responseRequired) respond(root.password)
      else if (message !== "") root.message = message
    }

    onCompleted: result => {
      root.password = ""
      if (result === PamResult.Success) { root.finish(); return }
      root.checking = false
      root.attempt += 1
      root.message = result === PamResult.Failed ? "Wrong password" : "Authentication error, try again"
    }

    onError: err => { root.checking = false; root.message = "Authentication error, try again" }
  }

  WlSessionLock {
    id: sessionLock
    locked: root.locked

    WlSessionLockSurface {
      id: surface
      color: Theme.bg

      Item {
        anchors.fill: parent

        Image {
          anchors.fill: parent
          visible: root.shotReady
          source: root.shotReady ? "file://" + root.shot : ""
          fillMode: Image.PreserveAspectCrop
          cache: false
          asynchronous: true
        }

        Rectangle { anchors.fill: parent; color: Theme.bg; opacity: root.shotReady ? 0.9 : 1.0 }

        SystemClock { id: tick; precision: Prefs.showSeconds ? SystemClock.Seconds : SystemClock.Minutes }

        ColumnLayout {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: -parent.height * 0.08
          spacing: Theme.spaceSm

          Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(tick.date, Prefs.timeFormat)
            color: Theme.bright
            font.pixelSize: Theme.fontDisplay * 2.4
            font.bold: true
          }
          Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.spaceLg * 2
            text: Qt.formatDate(tick.date, "dddd, d MMMM")
            color: Theme.fg
            font.pixelSize: Theme.fontLarge
          }

          Label {
            Layout.alignment: Qt.AlignHCenter
            text: Icons.user
            color: Theme.accent
            font.pixelSize: Theme.fontDisplay
          }
          Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.user
            color: Theme.bright
            font.pixelSize: Theme.fontLarge
            Layout.bottomMargin: Theme.spaceMd
          }

          TextField {
            id: field
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Theme.lockFieldWidth
            password: true
            placeholder: root.checking ? "Checking..." : "Password"
            enabled: !root.checking
            onAccepted: { root.submit(text); text = "" }
            Component.onCompleted: input.forceActiveFocus()
            Connections {
              target: root
              function onLockedChanged() { if (root.locked) field.input.forceActiveFocus() }
            }
            Keys.onEscapePressed: text = ""
          }

          Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Theme.rowHeight
            Layout.preferredWidth: Theme.lockFieldWidth
            horizontalAlignment: Text.AlignHCenter
            text: root.message
            color: Theme.danger
            font.pixelSize: Theme.fontBody
            SequentialAnimation on x {
              id: shake
              running: false
              NumberAnimation { to: -8; duration: 40 }
              NumberAnimation { to: 8; duration: 70 }
              NumberAnimation { to: 0; duration: 40 }
            }
          }
        }

        Connections {
          target: root
          function onAttemptChanged() { shake.restart(); field.input.forceActiveFocus() }
        }

        Row {
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.margins: Theme.spaceLg
          spacing: Theme.spaceLg
          visible: UPower.displayDevice && UPower.displayDevice.isPresent
          Label {
            text: (UPower.displayDevice.state === UPowerDeviceState.Charging ? Icons.bolt + " " : Icons.batteryFull + " ") + Math.round(UPower.displayDevice.percentage * 100) + "%"
            color: UPower.displayDevice.percentage < 0.15 ? Theme.danger : Theme.fg
            font.pixelSize: Theme.fontBody
          }
        }
      }
    }
  }
}
