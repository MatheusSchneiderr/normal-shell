pragma Singleton
import QtQuick
import Quickshell
import qs.services

Scope {
  id: root

  readonly property int users: poll.users
  property var devices: []
  property var details: ({})
  property var wifiRaw: []
  property var profiles: []
  property bool wifiOn: true
  property bool networking: true
  property string connectivity: ""
  property bool scanned: false
  property string message: ""
  property bool good: false

  readonly property bool busy: action.busy
  readonly property var wifi: devices.find(d => d.type === "wifi")
  readonly property string wifiDevice: wifi ? wifi.name : ""
  readonly property var wifiProfiles: profiles.filter(p => p.type === "802-11-wireless")
  readonly property var vpnProfiles: profiles.filter(p => p.type === "vpn" || p.type === "wireguard")
  readonly property var savedProfiles: profiles.filter(p => p.type !== "loopback")
  readonly property var networks: build(wifiRaw, wifiProfiles.map(p => p.name))
  readonly property var current: networks.find(n => n.active)
  readonly property string ip: {
    const info = details[wifiDevice]
    return info && info["IP4.ADDRESS[1]"] ? info["IP4.ADDRESS[1]"].split("/")[0] : ""
  }

  function hold() { poll.hold() }
  function release() { poll.release() }

  function build(list, saved) {
    return list.map(e => ({ ssid: e.ssid, signal: e.signal, secure: e.secure, active: e.active, band: e.band, saved: saved.indexOf(e.ssid) >= 0 }))
      .sort((a, b) => (b.active - a.active) || (b.saved - a.saved) || (b.signal - a.signal))
  }

  function bars(signal) { return signal > 75 ? "\u2582\u2584\u2586\u2588" : signal > 50 ? "\u2582\u2584\u2586" : signal > 25 ? "\u2582\u2584" : "\u2582" }

  function band(freq) {
    const mhz = parseInt(freq)
    return mhz >= 5925 ? "6 GHz" : mhz >= 4900 ? "5 GHz" : mhz > 0 ? "2.4 GHz" : ""
  }

  function refresh() {
    for (const c of [devCmd, showCmd, wifiCmd, profCmd, radioCmd, netCmd, connCmd]) if (!c.busy) c.run()
  }

  function rescanNow() { rescan.run(); refresh() }

  function run(args) { return action.run(args) }

  function setWifi(on) { run(["nmcli", "radio", "wifi", on ? "on" : "off"]) }
  function setNetworking(on) { run(["nmcli", "networking", on ? "on" : "off"]) }
  function connectWifi(ssid, password, hidden) {
    const args = ["nmcli", "device", "wifi", "connect", ssid]
    if (hidden) args.push("hidden", "yes")
    if (password) args.push("password", password)
    run(args)
  }
  function toggleNetwork(n, password) {
    if (n.active) run(["nmcli", "connection", "down", "id", n.ssid])
    else if (n.saved) run(["nmcli", "connection", "up", "id", n.ssid])
    else connectWifi(n.ssid, password, false)
  }
  function forget(ssid) { run(["nmcli", "connection", "delete", "id", ssid]) }
  function toggleProfile(p) { run(["nmcli", "connection", p.active ? "down" : "up", "uuid", p.uuid]) }

  Poller { id: poll; interval: 4000; onActivated: rescan.run(); onTick: root.refresh() }

  Cmd { id: rescan; command: ["nmcli", "device", "wifi", "rescan"] }

  Cmd {
    id: devCmd
    command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"]
    onFinished: (code, out) => {
      root.devices = root.rows(out).filter(r => r[1] !== "loopback" && r[1] !== "wifi-p2p").map(r => ({ name: r[0], type: r[1], state: r[2], connection: r[3] }))
    }
  }

  Cmd {
    id: showCmd
    command: ["nmcli", "-t", "device", "show"]
    onFinished: (code, out) => {
      const map = {}
      let cur = null
      for (const line of out.split("\n")) {
        const at = line.indexOf(":")
        if (at < 0) continue
        const key = line.slice(0, at)
        const value = line.slice(at + 1)
        if (key === "GENERAL.DEVICE") { cur = {}; map[value] = cur }
        if (cur) cur[key] = (cur[key] ? cur[key] + "\n" : "") + value
      }
      root.details = map
    }
  }

  Cmd {
    id: wifiCmd
    command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY,FREQ", "device", "wifi", "list"]
    onFinished: (code, out) => {
      const best = {}
      for (const r of root.rows(out)) {
        if (r[1] === "") continue
        const entry = { ssid: r[1], signal: parseInt(r[2]) || 0, secure: r[3] !== "", active: r[0] === "*", band: root.band(r[4]) }
        const old = best[r[1]]
        if (!old || entry.active || (!old.active && entry.signal > old.signal)) best[r[1]] = entry
      }
      root.wifiRaw = Object.values(best)
      root.scanned = true
    }
  }

  Cmd {
    id: profCmd
    command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,ACTIVE,AUTOCONNECT", "connection", "show"]
    onFinished: (code, out) => {
      root.profiles = root.rows(out).map(r => ({ name: r[0], uuid: r[1], type: r[2], active: r[3] === "yes", auto: r[4] === "yes" }))
    }
  }

  Cmd { id: radioCmd; command: ["nmcli", "radio", "wifi"]; onFinished: (code, out) => root.wifiOn = out.trim() === "enabled" }
  Cmd { id: netCmd; command: ["nmcli", "networking"]; onFinished: (code, out) => root.networking = out.trim() === "enabled" }
  Cmd { id: connCmd; command: ["nmcli", "networking", "connectivity"]; onFinished: (code, out) => root.connectivity = out.trim() }

  Cmd {
    id: action
    onFinished: (code, out, err) => {
      root.good = code === 0
      root.message = code === 0 ? "" : (Util.firstLine(err) || "Failed")
      root.refresh()
    }
  }

  function fields(line) {
    const out = []
    let cur = ""
    for (let i = 0; i < line.length; i++) {
      const c = line[i]
      if (c === "\\" && i + 1 < line.length) { cur += line[i + 1]; i++ }
      else if (c === ":") { out.push(cur); cur = "" }
      else cur += c
    }
    out.push(cur)
    return out
  }

  function rows(text) {
    return text.split("\n").filter(l => l.length > 0).map(fields)
  }

  function pairs(text) {
    const out = {}
    for (const line of text.split("\n")) {
      const at = line.indexOf(":")
      if (at < 0) continue
      out[line.slice(0, at)] = line.slice(at + 1).replace(/\\:/g, ":").replace(/\\\\/g, "\\")
    }
    return out
  }

  function typeLabel(type) {
    switch (type) {
    case "802-11-wireless": case "wifi": return "Wi-Fi"
    case "802-3-ethernet": case "ethernet": return "Ethernet"
    case "vpn": return "VPN"
    case "wireguard": return "WireGuard"
    case "loopback": return "Loopback"
    case "bridge": return "Bridge"
    case "tun": return "Tunnel"
    case "dummy": return "Dummy"
    default: return type
    }
  }
}
