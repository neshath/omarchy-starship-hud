import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property bool ipcEnabled: true
  readonly property real cpuPercent: cpu
  readonly property real memoryPercent: memory
  readonly property real temperatureC: temperature
  readonly property real uptimeSeconds: uptime
  readonly property bool networkUp: network === "up"
  readonly property string networkState: network
  readonly property string source: "LOCAL"
  readonly property string lastError: errorText

  property real cpu: 0
  property real memory: 0
  property real temperature: 0
  property real uptime: 0
  property string network: "unknown"
  property string errorText: ""
  property real previousTotal: -1
  property real previousIdle: -1

  function sample() {
    if (!sampler.running) sampler.running = true
  }

  function parseSample(payload) {
    var fields = String(payload || "").trim().split("|")
    if (fields.length < 7) {
      errorText = "Telemetry sample was incomplete"
      return
    }

    var total = Number(fields[0])
    var idle = Number(fields[1])
    var memTotal = Number(fields[2])
    var memAvailable = Number(fields[3])
    var nextUptime = Number(fields[4])
    var rawTemperature = Number(fields[5])
    var nextNetwork = fields[6] || "unknown"

    if (isFinite(total) && isFinite(idle) && previousTotal >= 0 && total > previousTotal) {
      var totalDelta = total - previousTotal
      var idleDelta = Math.max(0, idle - previousIdle)
      cpu = Math.max(0, Math.min(100, 100 * (1 - idleDelta / totalDelta)))
    }
    previousTotal = total
    previousIdle = idle

    if (isFinite(memTotal) && memTotal > 0 && isFinite(memAvailable)) {
      memory = Math.max(0, Math.min(100, 100 * (1 - memAvailable / memTotal)))
    }
    if (isFinite(nextUptime)) uptime = Math.max(0, nextUptime)
    if (isFinite(rawTemperature) && rawTemperature > 0) {
      temperature = rawTemperature > 1000 ? rawTemperature / 1000 : rawTemperature
    }
    network = nextNetwork
    errorText = ""
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.sample()
  }

  Process {
    id: sampler
    command: ["sh", "-c", "cpu=$(awk '/^cpu / {t=0; for(i=2;i<=NF;i++) t+=$i; print t, $5+$6; exit}' /proc/stat); mem=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {print t, a}' /proc/meminfo); up=$(awk '{print $1}' /proc/uptime); temp=$(for f in /sys/class/thermal/thermal_zone*/temp; do if [ -r \"$f\" ]; then cat \"$f\"; break; fi; done); temp=${temp:-0}; net=$(for f in /sys/class/net/*/operstate; do case \"$f\" in */lo/operstate) continue;; esac; if [ \"$(cat \"$f\")\" = up ]; then echo up; break; fi; done); net=${net:-down}; set -- $cpu $mem $up $temp $net; printf '%s|%s|%s|%s|%s|%s|%s\\n' \"$1\" \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\""]
    stdout: StdioCollector {
      onStreamFinished: root.parseSample(text)
    }
    onExited: running = false
  }

  IpcHandler {
    enabled: root.ipcEnabled
    target: "neshath.starship-hud"

    function status(): string {
      return JSON.stringify({
        source: root.source,
        cpuPercent: root.cpuPercent,
        memoryPercent: root.memoryPercent,
        temperatureC: root.temperatureC,
        uptimeSeconds: root.uptimeSeconds,
        networkUp: root.networkUp,
        networkState: root.networkState,
        lastError: root.lastError
      })
    }
  }
}
