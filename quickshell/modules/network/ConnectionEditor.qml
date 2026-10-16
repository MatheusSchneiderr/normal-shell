import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  id: root
  property string uuid: ""
  property string name: ""
  signal back()
  signal changed()

  spacing: Theme.spaceMd

  property var original: ({})
  property var draft: ({})
  property string password: ""
  property string originalPassword: ""
  property string message: ""
  property bool good: false
  readonly property string type: original["connection.type"] || ""
  readonly property string prefix: type === "802-11-wireless" ? "802-11-wireless" : type === "802-3-ethernet" ? "802-3-ethernet" : ""
  readonly property bool isWifi: type === "802-11-wireless"
  readonly property bool isVpn: type === "vpn" || type === "wireguard"
  readonly property bool loaded: Object.keys(original).length > 0

  readonly property var keys: [
    "connection.autoconnect", "connection.autoconnect-priority", "connection.metered", "connection.type",
    "ipv4.method", "ipv4.addresses", "ipv4.gateway", "ipv4.dns", "ipv4.dns-search", "ipv4.ignore-auto-dns", "ipv4.never-default", "ipv4.route-metric",
    "ipv6.method", "ipv6.addresses", "ipv6.gateway", "ipv6.dns", "ipv6.ignore-auto-dns", "ipv6.never-default"
  ].concat(prefix !== "" ? [prefix + ".mtu", prefix + ".cloned-mac-address"] : [])
    .concat(isWifi ? ["802-11-wireless.hidden", "802-11-wireless.ssid", "802-11-wireless-security.key-mgmt"] : [])
    .concat(isVpn ? ["vpn.service-type", "vpn.data"] : [])

  function get(key) { return draft[key] !== undefined ? draft[key] : "" }
  function set(key, value) {
    if (draft[key] === value) return
    const copy = Object.assign({}, draft)
    copy[key] = value
    draft = copy
  }
  function flag(key) { return get(key) === "yes" }

  function load() {
    message = ""
    typeProbe.run(["nmcli", "-t", "-f", "connection.type", "connection", "show", "uuid", uuid])
  }

  onUuidChanged: if (uuid !== "") load()

  Cmd {
    id: typeProbe
    onFinished: (code, out, err) => {
      if (code !== 0) { root.message = Util.firstLine(err) || "Could not read connection"; return }
      root.original = Nm.pairs(out)
      fetch.run(["nmcli", "-t", "-f", root.keys.join(","), "connection", "show", "uuid", root.uuid])
    }
  }

  Cmd {
    id: fetch
    onFinished: (code, out, err) => {
      if (code !== 0) { root.message = Util.firstLine(err) || "Could not read connection"; return }
      root.original = Nm.pairs(out)
      root.draft = Object.assign({}, root.original)
      if (root.isWifi && (root.original["802-11-wireless-security.key-mgmt"] || "") !== "") secret.run(["nmcli", "-s", "-g", "802-11-wireless-security.psk", "connection", "show", "uuid", root.uuid])
      else { root.password = ""; root.originalPassword = "" }
    }
  }

  Cmd {
    id: secret
    onFinished: (code, out, err) => { root.password = out.trim(); root.originalPassword = root.password }
  }

  Cmd {
    id: save
    property bool reconnect: false
    onFinished: (code, out, err) => {
      if (code !== 0) { root.good = false; root.message = Util.firstLine(err) || "Failed to save"; return }
      if (reconnect) up.run(["nmcli", "connection", "up", "uuid", root.uuid])
      root.good = true
      root.message = reconnect ? "Saved, reconnecting..." : "Saved"
      root.changed()
      fetch.run(["nmcli", "-t", "-f", root.keys.join(","), "connection", "show", "uuid", root.uuid])
    }
  }

  Cmd {
    id: up
    onFinished: (code, out, err) => {
      root.good = code === 0
      root.message = code === 0 ? "Reconnected" : (Util.firstLine(err) || "Could not reconnect")
      root.changed()
    }
  }

  Cmd {
    id: remove
    onFinished: (code, out, err) => {
      if (code !== 0) { root.good = false; root.message = Util.firstLine(err) || "Could not delete"; return }
      root.changed()
      root.back()
    }
  }

  function apply(reconnect) {
    const args = ["nmcli", "connection", "modify", "uuid", uuid]
    let count = 0
    for (const key of keys) {
      if (key === "connection.type" || key === "802-11-wireless.ssid" || key === "802-11-wireless-security.key-mgmt" || key.startsWith("vpn.")) continue
      if (draft[key] !== original[key]) { args.push(key, draft[key]); count++ }
    }
    if (isWifi && password !== originalPassword) { args.push("802-11-wireless-security.psk", password); count++ }
    if (count === 0 && !reconnect) { good = true; message = "No changes"; return }
    if (count === 0) { up.run(["nmcli", "connection", "up", "uuid", uuid]); return }
    save.reconnect = reconnect
    save.run(args)
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: Theme.spaceMd
    ActionButton { text: "←  Back"; onActivated: root.back() }
    Label {
      Layout.fillWidth: true
      text: root.name + "   " + Nm.typeLabel(root.type)
      color: Theme.bright
      font.pixelSize: Theme.fontLarge
      font.bold: true
      elide: Text.ElideRight
    }
  }

  StatusMessage { text: root.message; ok: root.good }

  SectionHeader { text: "GENERAL"; visible: root.loaded }
  FormRow {
    visible: root.loaded
    label: "Connect automatically"
    Toggle { checked: root.flag("connection.autoconnect"); onToggled: v => root.set("connection.autoconnect", v ? "yes" : "no") }
  }
  FormRow {
    visible: root.loaded
    label: "Priority"
    hint: "Higher wins when several saved networks are in range"
    TextField { text: root.get("connection.autoconnect-priority"); onTextChanged: root.set("connection.autoconnect-priority", text) }
  }
  FormRow {
    visible: root.loaded
    label: "Metered connection"
    hint: "Apps may use less data"
    Dropdown {
      value: root.get("connection.metered") === "yes (guessed)" ? "yes" : root.get("connection.metered") === "no (guessed)" ? "no" : root.get("connection.metered")
      options: [{ label: "Automatic", value: "unknown" }, { label: "Yes", value: "yes" }, { label: "No", value: "no" }]
      onPicked: v => root.set("connection.metered", v)
    }
  }
  FormRow {
    visible: root.isWifi
    label: "Password"
    TextField { password: true; text: root.password; placeholder: "WPA passphrase"; onTextChanged: root.password = text }
  }
  FormRow {
    visible: root.isWifi
    label: "Hidden network"
    Toggle { checked: root.flag("802-11-wireless.hidden"); onToggled: v => root.set("802-11-wireless.hidden", v ? "yes" : "no") }
  }

  SectionHeader { text: "IPV4"; visible: root.loaded }
  FormRow {
    visible: root.loaded
    label: "Method"
    Dropdown {
      value: root.get("ipv4.method")
      options: [{ label: "Automatic (DHCP)", value: "auto" }, { label: "Manual (static)", value: "manual" }, { label: "Link-local only", value: "link-local" }, { label: "Disabled", value: "disabled" }]
      onPicked: v => root.set("ipv4.method", v)
    }
  }
  FormRow {
    visible: root.loaded && root.get("ipv4.method") === "manual"
    label: "Address"
    hint: "e.g. 192.168.1.20/24 (comma-separated)"
    TextField { Layout.fillWidth: true; text: root.get("ipv4.addresses"); onTextChanged: root.set("ipv4.addresses", text) }
  }
  FormRow {
    visible: root.loaded && root.get("ipv4.method") === "manual"
    label: "Gateway"
    TextField { text: root.get("ipv4.gateway"); onTextChanged: root.set("ipv4.gateway", text) }
  }
  FormRow {
    visible: root.loaded
    label: "DNS servers"
    hint: "Comma-separated, e.g. 1.1.1.1, 9.9.9.9"
    TextField { Layout.fillWidth: true; text: root.get("ipv4.dns"); onTextChanged: root.set("ipv4.dns", text) }
  }
  FormRow {
    visible: root.loaded
    label: "Search domains"
    TextField { Layout.fillWidth: true; text: root.get("ipv4.dns-search"); onTextChanged: root.set("ipv4.dns-search", text) }
  }
  FormRow {
    visible: root.loaded
    label: "Ignore automatic DNS"
    hint: "Use only the DNS servers above"
    Toggle { checked: root.flag("ipv4.ignore-auto-dns"); onToggled: v => root.set("ipv4.ignore-auto-dns", v ? "yes" : "no") }
  }
  FormRow {
    visible: root.loaded
    label: "Never use as default route"
    hint: "Keep other connections for internet traffic"
    Toggle { checked: root.flag("ipv4.never-default"); onToggled: v => root.set("ipv4.never-default", v ? "yes" : "no") }
  }
  FormRow {
    visible: root.loaded
    label: "Route metric"
    hint: "-1 = automatic"
    TextField { text: root.get("ipv4.route-metric"); onTextChanged: root.set("ipv4.route-metric", text) }
  }

  SectionHeader { text: "IPV6"; visible: root.loaded }
  FormRow {
    visible: root.loaded
    label: "Method"
    Dropdown {
      value: root.get("ipv6.method")
      options: [{ label: "Automatic", value: "auto" }, { label: "DHCP only", value: "dhcp" }, { label: "Manual (static)", value: "manual" }, { label: "Link-local only", value: "link-local" }, { label: "Ignore", value: "ignore" }, { label: "Disabled", value: "disabled" }]
      onPicked: v => root.set("ipv6.method", v)
    }
  }
  FormRow {
    visible: root.loaded && root.get("ipv6.method") === "manual"
    label: "Address"
    hint: "e.g. fd00::10/64"
    TextField { Layout.fillWidth: true; text: root.get("ipv6.addresses"); onTextChanged: root.set("ipv6.addresses", text) }
  }
  FormRow {
    visible: root.loaded && root.get("ipv6.method") === "manual"
    label: "Gateway"
    TextField { text: root.get("ipv6.gateway"); onTextChanged: root.set("ipv6.gateway", text) }
  }
  FormRow {
    visible: root.loaded
    label: "DNS servers"
    TextField { Layout.fillWidth: true; text: root.get("ipv6.dns"); onTextChanged: root.set("ipv6.dns", text) }
  }

  SectionHeader { text: "HARDWARE"; visible: root.prefix !== "" }
  FormRow {
    visible: root.prefix !== ""
    label: "MTU"
    hint: "auto or a number such as 1400"
    TextField { text: root.get(root.prefix + ".mtu"); onTextChanged: root.set(root.prefix + ".mtu", text === "" ? "auto" : text) }
  }
  FormRow {
    visible: root.prefix !== ""
    label: "MAC address"
    hint: "Random hides your device from the network"
    Dropdown {
      value: root.get(root.prefix + ".cloned-mac-address")
      options: [{ label: "Default", value: "" }, { label: "Permanent hardware", value: "permanent" }, { label: "Preserve", value: "preserve" }, { label: "Random each connect", value: "random" }, { label: "Stable per network", value: "stable" }]
      onPicked: v => root.set(root.prefix + ".cloned-mac-address", v)
    }
  }

  SectionHeader { text: "VPN"; visible: root.isVpn }
  Label {
    visible: root.isVpn
    text: root.get("vpn.service-type") + "\n" + root.get("vpn.data").replace(/,\s*/g, "\n")
    color: Theme.muted
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }

  RowLayout {
    visible: root.loaded
    Layout.fillWidth: true
    Layout.topMargin: Theme.spaceMd
    spacing: Theme.spaceMd
    ActionButton { text: "Save"; primary: true; busy: save.busy; onActivated: root.apply(false) }
    ActionButton { text: "Save and reconnect"; onActivated: root.apply(true) }
    ActionButton { text: "Revert"; onActivated: root.load() }
    Item { Layout.fillWidth: true }
    ConfirmButton {
      label: "Delete"
      question: "Really delete?"
      onConfirmed: remove.run(["nmcli", "connection", "delete", "uuid", root.uuid])
    }
  }
}
