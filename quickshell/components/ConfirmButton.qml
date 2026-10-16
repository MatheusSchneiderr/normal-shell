import QtQuick

ActionButton {
  id: root
  property string label: "Delete"
  property string question: "Really delete?"
  property bool armed: false
  signal confirmed()

  danger: true
  text: armed ? question : label
  onActivated: {
    if (!armed) { armed = true; reset.restart(); return }
    armed = false
    confirmed()
  }

  Timer { id: reset; interval: 4000; onTriggered: root.armed = false }
}
