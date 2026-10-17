import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Scope {
  id: root

  IpcHandler {
    target: "screenshot"
    function region(): void { if (!selector.busy) selector.run() }
    function full(): void { root.capture("") }
  }

  function notify(summary, body) {
    Quickshell.execDetached(["busctl", "--user", "call", "org.freedesktop.Notifications", "/org/freedesktop/Notifications",
      "org.freedesktop.Notifications", "Notify", "susssasa{sv}i", "Screenshots", "0", "", summary, body, "0", "0", "5000"])
  }

  // swappy saves its own edited copy next to the original, so point it at the same folder
  function edit(path) {
    Quickshell.execDetached(["sh", "-c",
      'mkdir -p "$HOME/.config/swappy" && printf "[Default]\\nsave_dir=%s\\nsave_filename_format=Screenshot_%%Y%%m%%d-%%H%%M%%S-edited.png\\n" "$1" > "$HOME/.config/swappy/config"; exec swappy -f "$2"',
      "sh", Prefs.screenshotDir, path])
  }

  function capture(area) {
    const path = Prefs.screenshotDir + "/Screenshot_" + Qt.formatDateTime(new Date(), "yyyyMMdd-HHmmss") + ".png"
    shot.path = path
    shot.run(["sh", "-c",
      'mkdir -p "$1" && if [ -n "$3" ]; then grim -g "$3" "$2"; else grim "$2"; fi && { [ "$4" != 1 ] || wl-copy --type image/png < "$2" > /dev/null 2>&1; }',
      "sh", Prefs.screenshotDir, path, area, Prefs.screenshotCopy ? "1" : "0"])
  }

  Cmd {
    id: selector
    // slurp waits for predefined regions on stdin, so give it an empty one
    command: ["sh", "-c", "exec slurp < /dev/null"]
    onFinished: (code, out, err) => { if (code === 0 && out.trim() !== "") root.capture(out.trim()) }
  }

  Cmd {
    id: shot
    property string path: ""
    onFinished: (code, out, err) => {
      if (code !== 0) { root.notify("Screenshot failed", Util.firstLine(err) || "Could not capture the screen"); return }
      root.notify("Screenshot saved", path + (Prefs.screenshotCopy ? "\nCopied to the clipboard" : ""))
      if (Prefs.screenshotEdit) root.edit(path)
    }
  }
}
