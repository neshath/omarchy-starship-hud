import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "neshath.starship-hud"

  readonly property string mission: String(setting("mission", "STARSHIP FLIGHT 14"))
  readonly property int demoSpeed: Number(setting("speed", 26370))
  readonly property int demoAltitude: Number(setting("altitude", 276))
  readonly property bool showIcons: setting("showIcons", true) === true
  readonly property bool useLocalTelemetry: setting("useLocalTelemetry", true) === true
  readonly property var telemetry: serviceSource.service
  readonly property int speed: demoSpeed
  readonly property int altitude: demoAltitude
  readonly property real cpuPercent: useLocalTelemetry && telemetry ? telemetry.cpuPercent : 0
  readonly property real memoryPercent: useLocalTelemetry && telemetry ? telemetry.memoryPercent : 0
  readonly property real temperatureC: useLocalTelemetry && telemetry ? telemetry.temperatureC : 0
  readonly property bool networkUp: useLocalTelemetry && telemetry ? telemetry.networkUp : false
  readonly property color cyan: "#00e5ff"
  readonly property color softCyan: "#8deaf4"
  readonly property color panel: "#06131b"
  readonly property color ink: "#d8f7ff"
  readonly property int pad: 10

  implicitWidth: vertical ? barSize : Math.min(1080, Math.max(680, content.implicitWidth + pad * 2))
  implicitHeight: barSize
  clip: true

  ServiceSource {
    id: serviceSource
    bar: root.bar
    serviceId: root.moduleName
    fallback: Component {
      TelemetryService { ipcEnabled: false }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: panel
    opacity: 0.96
    border.color: cyan
    border.width: 1
    radius: 2
  }

  Row {
    id: content
    anchors.fill: parent
    anchors.margins: root.pad
    spacing: 14

    Item {
      width: 92
      height: parent.height
      Text { anchors.centerIn: parent; text: "SPEED\n" + root.speed + "\nKM/H"; color: root.ink; font.family: "monospace"; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
      Rectangle { anchors.fill: parent; color: "transparent"; border.color: root.cyan; border.width: 1; radius: height / 2 }
    }

    Item {
      width: 270
      height: parent.height
      Text { anchors.horizontalCenter: parent.horizontalCenter; y: 1; text: "T+ 00:25:38"; color: root.ink; font.family: "monospace"; font.pixelSize: 21 }
      Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; text: root.mission; color: root.cyan; font.family: "monospace"; font.pixelSize: 11 }
      Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; color: root.cyan; height: 1; opacity: 0.55 }
    }

    Item {
      width: 92
      height: parent.height
      Text { anchors.centerIn: parent; text: "ALTITUDE\n" + root.altitude + "\nKM"; color: root.ink; font.family: "monospace"; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
      Rectangle { anchors.fill: parent; color: "transparent"; border.color: root.cyan; border.width: 1; radius: height / 2 }
    }

    Column {
      width: 150
      height: parent.height
      spacing: 1
      Text { text: "CPU " + Math.round(root.cpuPercent) + "%"; color: root.softCyan; font.family: "monospace"; font.pixelSize: 10 }
      Text { text: "RAM " + Math.round(root.memoryPercent) + "%"; color: root.softCyan; font.family: "monospace"; font.pixelSize: 10 }
      Text { text: "TEMP " + (root.temperatureC > 0 ? Math.round(root.temperatureC) + "°C" : "—"); color: root.softCyan; font.family: "monospace"; font.pixelSize: 10 }
      Text { text: "NET " + (root.networkUp ? "UP" : "DOWN"); color: root.networkUp ? root.cyan : "#ff647c"; font.family: "monospace"; font.pixelSize: 10 }
    }

    Row {
      visible: root.showIcons
      anchors.verticalCenter: parent.verticalCenter
      spacing: 12
      Text { text: "△"; color: root.cyan; font.pixelSize: 22 }
      Text { text: "♨"; color: root.cyan; font.pixelSize: 22 }
      Text { text: "〰"; color: root.cyan; font.pixelSize: 22 }
      Text { text: "▮▮▮"; color: root.cyan; font.pixelSize: 16 }
    }
  }
}
