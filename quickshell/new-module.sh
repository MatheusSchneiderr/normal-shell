#!/usr/bin/env bash
# Usage: ./new-module.sh <name>   (lowercase, e.g. nightlight)
set -euo pipefail
cd "$(dirname "$0")"
name="${1:?usage: new-module.sh <name>}"
[[ "$name" =~ ^[a-z][a-z0-9]*$ ]] || { echo "name must be lowercase letters/digits"; exit 1; }
dir="modules/$name"
[ -e "$dir" ] && { echo "$dir already exists"; exit 1; }
Name="$(tr '[:lower:]' '[:upper:]' <<< "${name:0:1}")${name:1}"
mkdir -p "$dir"

cat > "$dir/${Name}Tray.qml" <<EOF
import QtQuick
import qs
import qs.components
import qs.services

StatusButton {
  glyph: Icons.gear
  popup: "$name"
}
EOF

cat > "$dir/${Name}Popup.qml" <<EOF
import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

ColumnLayout {
  spacing: Theme.spaceMd

  SectionHeader { text: "${name^^}" }
  Label { text: "$Name" }
}
EOF

cat > "$dir/${Name}Page.qml" <<EOF
import QtQuick
import QtQuick.Layouts
import qs
import qs.components

SettingsPage {
  title: "$Name"

  SectionHeader { text: "${name^^}" }
  FormRow {
    label: "Example"
    Toggle {}
  }
}
EOF

cat > "services/${Name}.qml" <<EOF
pragma Singleton
import QtQuick

QtObject {
}
EOF

echo "Created $dir and services/${Name}.qml (the feature's state and commands). Now add:"
echo "  shell/Panel.qml          : import qs.modules.$name   and   ${Name}Tray {}   in the tray row"
echo "  shell/SettingsWindow.qml : { id: \"$name\", label: \"$Name\", icon: Icons.gear, file: \"../modules/$name/${Name}Page.qml\" }"
echo "Popup name for IPC/keybindings: $name   (quickshell -c panel ipc call popup toggle $name)"
echo "Then run ./check.sh"
