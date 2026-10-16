import QtQuick
import Quickshell.Io

Item {
  id: root
  visible: false
  property var command: []
  property string output: ""
  property string error: ""
  property int exitCode: 0
  property bool busy: false
  property int pending: 0
  signal finished(int code, string output, string error)

  property var queued: null

  // Starts the command; if one is already running the newest request is queued and starts when it finishes.
  function run(args) {
    if (busy) { queued = { args: args }; return false }
    if (args !== undefined) command = args
    busy = true
    pending = 3
    proc.command = command
    proc.running = true
    return true
  }

  function settle() {
    pending -= 1
    if (pending > 0) return
    busy = false
    finished(exitCode, output, error)
    if (queued !== null) {
      const next = queued
      queued = null
      run(next.args)
    }
  }

  Process {
    id: proc
    stdout: StdioCollector { onStreamFinished: { root.output = text; root.settle() } }
    stderr: StdioCollector { onStreamFinished: { root.error = text; root.settle() } }
    onExited: (code, status) => { root.exitCode = code; root.settle() }
  }
}
