import QtQuick
import qs

Item {
  id: root
  property real value: 0
  property real maximum: 1
  property int steps: 0
  property bool knobVisible: true
  signal moved(real v)

  readonly property int knob: Theme.knobSize
  readonly property real fraction: Math.max(0, Math.min(1, value / maximum))

  implicitHeight: Theme.sliderHeight
  activeFocusOnTab: true

  Keys.onLeftPressed: nudge(-1)
  Keys.onRightPressed: nudge(1)

  function nudge(direction) {
    const step = steps > 0 ? 1 / steps : 0.05
    moved(Math.max(0, Math.min(1, fraction + direction * step)) * maximum)
  }

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: Theme.trackHeight
    color: Theme.fillHover

    Rectangle {
      width: root.knobVisible ? root.knob / 2 + (root.width - root.knob) * root.fraction : root.width * root.fraction
      height: parent.height
      color: Theme.fillPrimary
    }
  }

  Repeater {
    model: root.steps > 0 ? root.steps + 1 : 0
    delegate: Rectangle {
      required property int index
      x: root.knob / 2 + (root.width - root.knob) * index / root.steps - 1
      anchors.verticalCenter: parent.verticalCenter
      width: 2
      height: Theme.tickHeight
      color: Theme.lineDivider
      z: -1
    }
  }

  Rectangle {
    visible: root.knobVisible
    width: root.knob
    height: root.knob
    radius: root.knob / 2
    x: (root.width - root.knob) * root.fraction
    anchors.verticalCenter: parent.verticalCenter
    color: (area.pressed || area.containsMouse || root.activeFocus) ? Theme.fillPrimary : Theme.textBody
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    enabled: root.enabled
    function setFrom(x) {
      let f = Math.max(0, Math.min(1, (x - root.knob / 2) / (width - root.knob)))
      if (root.steps > 0) f = Math.round(f * root.steps) / root.steps
      root.moved(f * root.maximum)
    }
    onPressed: mouse => setFrom(mouse.x)
    onPositionChanged: mouse => { if (pressed) setFrom(mouse.x) }
  }
}
