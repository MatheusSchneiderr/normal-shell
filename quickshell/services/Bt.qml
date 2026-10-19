pragma Singleton
import QtQuick
import qs

QtObject {
  function glyph(icon) {
    if (icon.indexOf("headset") >= 0 || icon.indexOf("headphone") >= 0 || icon.indexOf("audio") >= 0) return Icons.headphones
    if (icon.indexOf("keyboard") >= 0) return Icons.keyboard
    if (icon.indexOf("mouse") >= 0) return Icons.mouse
    if (icon.indexOf("phone") >= 0) return Icons.phone
    return Icons.bluetooth
  }

  function kind(icon) {
    const names = { "audio-headset": "Headset", "audio-headphones": "Headphones", "audio-card": "Speaker", "input-keyboard": "Keyboard", "input-mouse": "Mouse", "input-gaming": "Game controller", "phone": "Phone", "computer": "Computer", "input-tablet": "Tablet" }
    return names[icon] || icon || "Device"
  }

  function stateText(d) {
    return d.pairing ? "pairing..." : d.connected ? "connected" : d.paired ? "paired" : ""
  }
}
