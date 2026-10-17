import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components
import qs.services

SettingsPage {
  title: "Screenshots"

  FormRow {
    label: "Save to"
    hint: "Press Enter to apply"
    TextField {
      Layout.fillWidth: true
      text: Prefs.screenshotDir
      onAccepted: Prefs.screenshotDir = text.replace(/^~/, Quickshell.env("HOME")).replace(/\/+$/, "")
    }
  }

  FormRow {
    label: "Copy to the clipboard"
    hint: "Right after the capture"
    Toggle { checked: Prefs.screenshotCopy; onToggled: v => Prefs.screenshotCopy = v }
  }

  FormRow {
    label: "Open the editor"
    hint: "Draw on the picture. Saving there adds a second copy ending in -edited"
    Toggle { checked: Prefs.screenshotEdit; onToggled: v => Prefs.screenshotEdit = v }
  }

  Label {
    text: "Print captures an area, Super+Print the whole screen. Files are named Screenshot_date-time.png."
    color: Theme.textHint
    wrapMode: Text.Wrap
    Layout.fillWidth: true
  }
}
