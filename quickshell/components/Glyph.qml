import QtQuick
import QtQuick.Layouts
import qs

Text {
  id: root
  // Icon glyphs are laid out with a different width than they are painted with, so horizontal
  // centering by alignment is a few pixels off. With centered: true the glyph is placed by position instead.
  property bool centered: false

  color: Theme.iconBody
  font.family: Theme.font
  font.pixelSize: Theme.iconNormal
  horizontalAlignment: centered ? Text.AlignLeft : Text.AlignHCenter
  Layout.preferredWidth: Theme.iconSlot

  Binding { target: root; property: "x"; value: Math.round((root.parent.width - root.width) / 2); when: root.centered && root.parent }
  Binding { target: root; property: "y"; value: Math.round((root.parent.height - root.height) / 2); when: root.centered && root.parent }
}
