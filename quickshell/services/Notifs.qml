pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.services

Scope {
  id: root
  readonly property var model: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length
  property var toasts: []
  property var times: ({})
  readonly property int maxHistory: 50

  function show(n) { toasts = [n].concat(toasts.filter(t => t !== n)).slice(0, 5) }
  function hide(n) { toasts = toasts.filter(t => t !== n) }
  function clear() {
    const all = server.trackedNotifications.values.slice()
    toasts = []
    for (const n of all) n.dismiss()
  }
  function stamp(n) {
    const when = times[n.id]
    return when ? Qt.formatTime(when, Prefs.clock24h ? "HH:mm" : "h:mm AP") : ""
  }

  // Keep only the newest notifications so history cannot grow without bound
  Connections {
    target: server.trackedNotifications
    function onObjectInsertedPost() {
      const all = server.trackedNotifications.values
      for (const old of all.slice(0, Math.max(0, all.length - root.maxHistory))) old.dismiss()
    }
  }

  NotificationServer {
    id: server
    bodySupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: false
    actionsSupported: true
    imageSupported: true
    persistenceSupported: true
    keepOnReload: false

    onNotification: n => {
      n.tracked = true
      const kept = {}
      for (const t of server.trackedNotifications.values) if (root.times[t.id]) kept[t.id] = root.times[t.id]
      kept[n.id] = new Date()
      root.times = kept
      if (!Prefs.dnd || n.urgency === NotificationUrgency.Critical) root.show(n)
    }
  }
}
