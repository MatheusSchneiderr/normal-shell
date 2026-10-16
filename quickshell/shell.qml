import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.shell
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.screencast
import qs.modules.appearance
import qs.modules.calendar
import qs.modules.windows

ShellRoot {
  IpcHandler {
    target: "start"
    function toggle(): void { Ui.toggleMenu() }
    function power(): void { Ui.menuOpen = true }
  }

  IpcHandler {
    target: "settings"
    function open(page: string): void { Ui.openSettings(page) }
    function close(): void { Ui.settingsOpen = false }
    function toggle(): void { if (Ui.settingsOpen) Ui.settingsOpen = false; else Ui.openSettings("") }
  }

  IpcHandler {
    target: "popup"
    function current(): string { return Ui.popup }
    function toggle(name: string): void { Ui.togglePopup(name) }
  }

  Variants {
    model: Quickshell.screens
    Panel {}
  }

  LazyLoader {
    active: Ui.popup !== ""
    PopupHost {
      current: Ui.popup
      onCloseRequested: Ui.popup = ""
    }
  }

  LazyLoader {
    active: Ui.settingsOpen
    SettingsWindow {
      visible: true
      page: Ui.settingsPage
      onPageChanged: Ui.settingsPage = page
      onCloseRequested: Ui.settingsOpen = false
    }
  }

  Launcher {}

  Wallpaper {}

  WayfireTheme {}

  KeyboardLayout {}

  LockScreen {}

  ResizeMode {}

  ScreencastPicker {}

  NotificationToasts {}

  StartMenu {
    open: Ui.menuOpen
    onSettingsRequested: Ui.openSettings("network")
    onCloseRequested: Ui.menuOpen = false
  }
}
