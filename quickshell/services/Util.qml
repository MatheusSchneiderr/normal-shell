pragma Singleton
import QtQuick

QtObject {
  function firstLine(text) { return text.trim().split("\n")[0] }
}
