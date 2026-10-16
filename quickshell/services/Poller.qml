import QtQuick
import Quickshell

// Counted polling: a service ticks only while at least one popup/page holds it.
Scope {
  id: root
  property int interval: 2000
  property int users: 0
  readonly property bool active: users > 0
  signal tick()
  signal activated()

  function hold() { users += 1; if (users === 1) activated(); tick() }
  function release() { users = Math.max(0, users - 1) }

  Timer { interval: root.interval; running: root.active; repeat: true; onTriggered: root.tick() }
}
