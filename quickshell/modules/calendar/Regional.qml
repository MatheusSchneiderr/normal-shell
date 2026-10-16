pragma Singleton
import QtQuick
import Quickshell
import qs.services

Scope {
  id: root
  property var info: ({})
  property string language: ""
  property var formatList: []
  property string layout: ""
  property string variant: ""

  readonly property string zone: info["Timezone"] || ""

  function hold() { poll.hold() }
  function release() { poll.release() }
  function refresh() { for (const c of [timeCmd, localeCmd, layoutCmd]) if (!c.busy) c.run() }

  Poller { id: poll; interval: 10000; onTick: root.refresh() }

  Cmd {
    id: timeCmd
    command: ["timedatectl", "show"]
    onFinished: (code, out) => {
      const map = {}
      for (const line of out.split("\n")) {
        const at = line.indexOf("=")
        if (at > 0) map[line.slice(0, at)] = line.slice(at + 1)
      }
      root.info = map
    }
  }

  Cmd {
    id: localeCmd
    command: ["localectl", "status"]
    onFinished: (code, out) => {
      const lines = out.split("\n").map(l => l.replace("System Locale:", "").trim()).filter(l => /^(LANG|LC_\w+)=/.test(l))
      const lang = lines.find(l => l.startsWith("LANG="))
      const formats = lines.filter(l => l.startsWith("LC_")).map(l => l.split("=")[1])
      root.language = lang ? lang.split("=")[1] : ""
      root.formatList = formats.filter((v, i) => formats.indexOf(v) === i)
    }
  }

  Cmd {
    id: layoutCmd
    command: ["sh", "-c", "grep -E '^xkb_(layout|variant)' \"$HOME/.config/wayfire.ini\""]
    onFinished: (code, out) => {
      const pick = key => { const m = new RegExp("^" + key + "\\s*=\\s*(.*)$", "m").exec(out); return m ? m[1].trim() : "" }
      root.layout = pick("xkb_layout")
      root.variant = pick("xkb_variant")
    }
  }
}
