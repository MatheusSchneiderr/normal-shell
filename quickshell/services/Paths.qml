pragma Singleton
import QtQuick
import Quickshell

QtObject {
  // Folder with the Wayfire helper scripts (QS_WAYFIRE_SCRIPTS lets dev/smoke.sh point at the repo)
  readonly property string wayfire: Quickshell.env("QS_WAYFIRE_SCRIPTS") || (Quickshell.env("HOME") + "/.config/wayfire")
}
