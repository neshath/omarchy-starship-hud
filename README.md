# Omarchy Starship Flight HUD

A compact Quickshell bar widget that turns the Omarchy bar into a Starship-inspired mission console. It displays a mission timer, demo speed and altitude, plus local CPU, RAM, temperature, uptime, and network state in a cyan aerospace style.

## Install

```bash
omarchy plugin add https://github.com/neshath/omarchy-starship-hud.git --enable --yes
omarchy bar position bottom
omarchy bar move neshath.starship-hud --section center --index 0
```

Install the matching visual theme separately:

```bash
omarchy theme install https://github.com/neshath/omarchy-starship-theme
```

## Local telemetry service

`TelemetryService.qml` is registered as a `service` and samples local, read-only Linux sources every two seconds:

- `/proc/stat` — CPU utilization
- `/proc/meminfo` — RAM utilization
- `/proc/uptime` — uptime
- `/sys/class/thermal/thermal_zone*/temp` — temperature when exposed by the kernel
- `/sys/class/net/*/operstate` — whether a non-loopback interface is up

The service performs no network requests, installs no packages, invokes no sudo commands, and does not read credentials. If a sensor is unavailable, the HUD shows a neutral fallback rather than failing.

The service also exposes a small IPC status payload through the plugin target:

```bash
omarchy-shell shell call neshath.starship-hud status
```

Availability of the shell IPC wrapper varies by Omarchy version; the HUD itself does not depend on this command.

## Settings

The widget exposes these settings through its manifest:

- `mission` — mission label, default `STARSHIP FLIGHT 14`.
- `speed` — demo speed in km/h, default `26370`.
- `altitude` — demo altitude in km, default `276`.
- `showIcons` — show the vehicle, engine, signal, and data indicators.
- `useLocalTelemetry` — use live local system values, default `true`.

The speed, altitude, and mission timer remain deterministic demo values. This plugin does not claim to provide live Starship telemetry.

## Validate locally

```bash
omarchy plugin validate .
```

The sandbox cannot execute this command because it is not an Omarchy/Quickshell session. Run it from a real Omarchy installation before publishing changes.

## Safety

This is an unsandboxed Quickshell plugin, as are Omarchy third-party plugins generally. Review the code before enabling it. The plugin contains only QML and a manifest. Its service reads local Linux status files and has no install hooks, sudo use, credential access, or network access.

## Compatibility

Target: Omarchy Quattro and later.

## License

MIT. See [LICENSE](LICENSE).
