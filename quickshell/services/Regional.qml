pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Scope {
  id: root
  property var info: ({})
  property string layout: ""
  property string variant: ""
  property bool onNixos: false

  // The language and formats this session runs with (a locale change restarts the panel with new ones)
  readonly property string language: Quickshell.env("LANG") || ""
  readonly property var formatList: formatKeys.map(k => Quickshell.env(k)).filter((v, i, all) => v && all.indexOf(v) === i)
  property var zones: []
  property var locales: []
  property var layouts: []
  property var variants: []

  // QS_DRYRUN=1 (dev/smoke.sh) turns every system-changing call into a no-op
  readonly property bool dryRun: Quickshell.env("QS_DRYRUN") === "1"
  readonly property var formatKeys: ["LC_ADDRESS", "LC_IDENTIFICATION", "LC_MEASUREMENT", "LC_MONETARY", "LC_NAME", "LC_NUMERIC", "LC_PAPER", "LC_TELEPHONE", "LC_TIME"]

  readonly property string zone: info["Timezone"] || ""

  function load() {
    if (zones.length === 0 && !zoneCmd.busy) zoneCmd.run()
    if (locales.length === 0 && !localeListCmd.busy) localeListCmd.run()
  }

  function hold() { load(); poll.hold() }
  function release() { poll.release() }
  function refresh() { for (const c of [timeCmd, layoutCmd]) if (!c.busy) c.run() }

  FileView {
    path: Quickshell.env("QS_OS_RELEASE") || "/etc/os-release"
    blockLoading: true
    printErrors: false
    onLoaded: root.onNixos = /^ID="?nixos"?$/m.test(text())
  }

  FileView {
    path: Quickshell.env("QS_XKB_LIST") || (Quickshell.env("HOME") + "/.config/quickshell/xkb-base.lst")
    blockLoading: true
    printErrors: false
    onLoaded: {
      const found = { layout: [], variant: [] }
      let section = ""
      for (const line of text().split("\n")) {
        if (line.startsWith("!")) { section = line.slice(1).trim(); continue }
        const m = /^\s+(\S+)\s+(.*)$/.exec(line)
        if (!m || (section !== "layout" && section !== "variant")) continue
        if (section === "layout") found.layout.push({ label: m[1] + "  " + m[2], value: m[1] })
        else {
          const v = /^([^:]+):\s*(.*)$/.exec(m[2])
          if (v) found.variant.push({ label: m[1] + "  " + v[2], value: m[1], layout: v[1] })
        }
      }
      root.layouts = found.layout
      root.variants = found.variant
    }
  }

  Cmd {
    id: zoneCmd
    command: ["timedatectl", "list-timezones"]
    onFinished: (code, out) => root.zones = out.split("\n").filter(z => z !== "")
  }

  Cmd {
    id: localeListCmd
    command: ["locale", "-a"]
    onFinished: (code, out) => {
      const names = out.split("\n").filter(l => /\.utf-?8$/i.test(l)).map(l => l.replace(/\.utf-?8$/i, ".UTF-8"))
      root.locales = names.filter(n => n !== "C.UTF-8")
    }
  }

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
    id: layoutCmd
    command: ["sh", "-c", "grep -E '^xkb_(layout|variant)' \"$HOME/.config/wayfire.ini\""]
    onFinished: (code, out) => {
      const pick = key => { const m = new RegExp("^" + key + "\\s*=\\s*(.*)$", "m").exec(out); return m ? m[1].trim() : "" }
      root.layout = pick("xkb_layout")
      root.variant = pick("xkb_variant")
    }
  }
}
