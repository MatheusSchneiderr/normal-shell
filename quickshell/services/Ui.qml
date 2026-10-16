pragma Singleton
import QtQuick

QtObject {
  property string popup: ""
  property bool menuOpen: false
  property bool settingsOpen: false
  property string settingsPage: "network"

  function togglePopup(name) {
    menuOpen = false
    popup = popup === name ? "" : name
  }

  function toggleMenu() {
    popup = ""
    menuOpen = !menuOpen
  }

  function openSettings(page) {
    if (page) settingsPage = page
    settingsOpen = true
    popup = ""
  }
}
