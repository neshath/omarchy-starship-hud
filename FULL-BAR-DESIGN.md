# Starship Mission Console — Full-Bar Design

## Goal

Replace the default Omarchy bar with a full-width, bottom-mounted mission console that feels like a Starship flight-control instrument while retaining essential desktop controls:

- Omarchy launcher
- Workspace switching
- Clock and status indicators
- System tray
- Network, audio, Bluetooth, display, and power access
- Mission telemetry visualization

The visual target is the supplied Starship desktop mockup: a dark translucent console with a curved upper edge, cyan blueprint lines, circular speed and altitude gauges, a central mission timer, and compact vehicle-status glyphs.

## Important implementation boundary

This is a **replacement `bar` plugin**, not a normal `bar-widget`.

A `bar-widget` is constrained by the built-in bar’s height, slots, and layout. The curved full-width console needs to own the bar surface, geometry, and widget placement, so it must declare:

```json
"kinds": ["bar"]
```

Only one full-bar plugin can be active at a time. If the plugin is invalid or removed, Omarchy should fall back to `omarchy.bar`.

Third-party replacement bars receive a restricted interface. Do not assume that every first-party service object is available through the replacement-bar host. The first release should therefore:

1. Render its own mission HUD locally.
2. Use detached bar-state data where available.
3. Prefer shell IPC/actions for essential controls.
4. Fail closed to inert labels rather than crashing if a service is unavailable.

## Visual layout

### Screen geometry

The bar is bottom-mounted and spans the available window width.

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│                         desktop / windows / wallpaper                       │
│                                                                              │
├─────────────── curved instrument rim / tick marks ──────────────────────────┤
│  SPEED          │                 T+ 00:25:38                 │   ALTITUDE   │
│  26370          │               STARSHIP FLIGHT 14           │     276      │  status
│  KM/H           │────────────────────────────────────────────│      KM       │ icons
└──────────────────────────────────────────────────────────────────────────────┘
```

### Recommended dimensions

Use responsive proportions rather than fixed screen coordinates:

- bar height: `116–150 px` at 1× scale
- top curved rim: `20–32 px`
- left gauge column: `18–23%` of width
- mission column: `42–50%` of width
- right gauge column: `18–23%` of width
- status column: remaining width, capped at `240 px`
- minimum usable width: `900 px`
- compact mode below `900 px`: hide labels and render icon-only gauges

The bar should use the current monitor’s logical width and `screen.devicePixelRatio`-safe logical sizes. Never assume 1920×1080.

## Component tree

```text
StarshipBar.qml
├── BarRoot / panel surface
├── CurvedRim.qml
│   ├── Canvas for arc
│   └── TickMarks.qml
├── LeftCluster.qml
│   └── Gauge.qml (Speed)
├── MissionCluster.qml
│   ├── MissionTimer.qml
│   ├── MissionTitle.qml
│   └── DividerLines.qml
├── RightCluster.qml
│   └── Gauge.qml (Altitude)
├── StatusCluster.qml
│   ├── VehicleGlyph.qml
│   ├── PropulsionGlyph.qml
│   ├── SignalGlyph.qml
│   └── DataBars.qml
├── OmarchyControls.qml
│   ├── LauncherButton
│   ├── WorkspaceStrip
│   └── Clock / system actions
└── Tooltips / popup bridges
```

Keep gauges and decorative geometry independent from shell integrations. That lets the console render even when a host service is unavailable.

## Manifest

Start from the current HUD repository and change the entry point to a full bar:

```json
{
  "schemaVersion": 1,
  "id": "neshath.starship-bar",
  "name": "Starship Mission Console",
  "version": "0.2.0",
  "author": "neshath",
  "license": "MIT",
  "description": "A full-width Starship-inspired replacement bar for Omarchy.",
  "kinds": ["bar"],
  "entryPoints": {
    "bar": "StarshipBar.qml"
  }
}
```

Keep the existing `neshath.starship-hud` repository as the compact widget. This replacement bar should either become a new repository or a clearly versioned major release, because enabling a full bar changes the user’s primary desktop shell surface.

## State model

### Demo state

The default state must be deterministic and local:

```qml
readonly property string mission: "STARSHIP FLIGHT 14"
readonly property int speedKmh: 26370
readonly property int altitudeKm: 276
readonly property string missionElapsed: "00:25:38"
readonly property string vehicleState: "NOMINAL"
```

### Local-system state

A later mode can map local values into the console:

- CPU utilization → `DATA` bars
- memory utilization → signal/data bars
- temperature → propulsion indicator
- uptime → mission timer fallback
- network reachability → signal glyph

Do not shell out from QML for this. If local telemetry is added, put it in a dedicated `service` plugin and expose only the scalar values required by the bar.

### Live mission state

Keep out of the first replacement-bar release. Live mission data would require:

- an explicitly documented provider
- stale-data timestamps
- unavailable/error states
- rate limiting
- user consent if a network request is made
- a service plugin rather than direct requests from visual QML

## Gauge design

Implement the circular gauges with `Canvas` or lightweight `Shape` primitives:

- dark circular plate
- thin cyan outer ring
- 24–36 segmented ticks
- active arc using a `Canvas` stroke
- centered numeric value
- unit label below
- small title above

Use a normalized value rather than hard-coding the arc:

```qml
readonly property real normalized: Math.max(0, Math.min(1, value / maximum))
readonly property real sweep: normalized * 270
```

The speed and altitude gauges should accept different maximums:

```qml
Gauge {
  title: "SPEED"
  value: telemetry.speedKmh
  maximum: 40000
  unit: "KM/H"
}

Gauge {
  title: "ALTITUDE"
  value: telemetry.altitudeKm
  maximum: 400
  unit: "KM"
}
```

## Curved rim

Use one `Canvas` for the upper console rim:

1. Fill the bar surface with a near-black translucent color.
2. Draw a shallow upward-facing arc from the left edge to the right edge.
3. Draw a cyan/blue 1 px border arc.
4. Draw evenly spaced tick marks along the arc.
5. Add a second low-opacity arc as a blueprint echo.

Avoid an SVG with a fixed viewport: a `Canvas` recomputes correctly for each monitor width.

Decorative geometry must never block mouse input. Set `acceptedButtons: Qt.NoButton` on noninteractive canvases.

## Essential controls

A full replacement bar must not remove basic navigation. Preserve these controls in a compact top strip or left-side cluster:

- Omarchy menu button
- workspace list
- clock
- network/audio/power access
- system tray

The mission console can be visually dominant while controls remain small and discoverable. A practical arrangement is:

```text
left:    Omarchy launcher + workspaces
center:  mission HUD
right:   clock + tray + audio/network/power
```

The console itself remains bottom-mounted; the control strip can sit along the console’s upper edge or inside its left/right gutters.

## Interaction contract

- Clicking a workspace changes focus to that workspace.
- Clicking the Omarchy glyph opens the standard menu.
- Clicking the clock opens the calendar.
- Clicking audio/network/power invokes the corresponding shell panel where the restricted host permits it.
- Gauges are read-only in v0.2.
- Hovering a gauge shows a tooltip with the value and source (`DEMO`, `LOCAL`, or `LIVE`).
- `Esc` and standard panel dismissal behavior must remain unchanged.

If a system action cannot be reached safely from the replacement-bar host, render the icon but make it inert with a clear tooltip rather than calling an undefined object.

## Responsive modes

### Full mode: width ≥ 1280 px

- both gauges with rings and labels
- full mission timer and title
- four status glyphs
- complete control strip

### Reduced mode: 900–1279 px

- smaller gauges
- shortened mission title
- two status glyphs
- compact clock

### Compact mode: width < 900 px

- hide gauge rings and show numeric chips
- show only mission title, timer, launcher, workspaces, and clock
- preserve keyboard access to all other panels

Use `Loader` or `visible` branches that do not instantiate expensive decorative canvases in compact mode.

## Theme integration

Do not hard-code the visual palette throughout the component. Define a small local mapping with Starship defaults and allow Omarchy theme values when available:

```qml
readonly property color hudAccent: "#00e5ff"
readonly property color hudText: "#d8f7ff"
readonly property color hudMuted: "#6f9aa8"
readonly property color hudSurface: "#06131b"
```

The matching `omarchy-starship-theme` supplies the global palette. The bar must still remain readable if a user enables it with another theme.

Use `BorderSurface` and `Border.surfaceSpec(...)` for interactive surfaces where the host API is available. Use flat local borders only for deliberate decorative blueprint lines.

## Validation plan

On a real Omarchy Quattro installation:

```bash
omarchy plugin validate .
omarchy plugin add https://github.com/neshath/omarchy-starship-bar.git --yes
omarchy plugin list --json
```

After enabling:

1. Confirm the bar appears at the bottom of every monitor.
2. Switch themes and verify the bar remains legible.
3. Resize from 1366×768 through 3440×1440.
4. Test 100%, 150%, and 200% display scale.
5. Switch workspaces and confirm click targets remain correct.
6. Open menu, calendar, network, audio, and power panels.
7. Toggle the default bar off by removing/disabling the replacement plugin and confirm `omarchy.bar` returns.
8. Restart the shell and log out/in.
9. Test with no network and with missing optional services.
10. Capture screenshots for the README.

## Rollback

The replacement bar must be easy to remove:

```bash
omarchy plugin disable neshath.starship-bar
omarchy plugin remove neshath.starship-bar
```

If the plugin remains selected or the shell does not recover automatically, restore the default bar through Omarchy’s plugin UI or by restoring `omarchy.bar` in the bar configuration. Do not require a package uninstall or system-file edit.

## Implementation phases

### Phase 1 — shell-safe skeleton

- `manifest.json` with `kinds: ["bar"]`
- full-width bottom surface
- launcher/workspaces/clock placeholders
- no external services
- compact/reduced/full breakpoints

### Phase 2 — visual console

- curved rim
- tick marks
- `Gauge.qml`
- mission timer and title
- vehicle-status glyphs
- Starship theme token mapping

### Phase 3 — essential controls

- wire workspace switching
- wire launcher/menu
- wire clock/calendar
- wire supported system panels
- add safe fallbacks for restricted host APIs

### Phase 4 — local telemetry

- add a separate local telemetry service
- expose CPU, memory, temperature, and uptime
- add source labels and stale-state handling

### Phase 5 — release

- real Omarchy validation
- screenshots at multiple resolutions
- version `0.2.0`
- publish as `omarchy-starship-bar`
- document replacement-bar behavior and rollback
