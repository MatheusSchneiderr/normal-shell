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
      const copy = Object.assign({}, root.times)
      copy[n.id] = new Date()
      root.times = copy
      if (!Prefs.dnd || n.urgency === NotificationUrgency.Critical) root.show(n)
    }
  }
}
