# Omarchy Starship Flight HUD

A compact Quickshell bar widget that turns the Omarchy bar into a Starship-inspired mission console. It displays a mission timer, speed, altitude, and vehicle/engine/telemetry status glyphs in a cyan aerospace style.

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

## Validate locally

```bash
omarchy plugin validate .
```

## Settings

The widget exposes these settings through its manifest:

- `mission` — mission label, default `STARSHIP FLIGHT 14`.
- `speed` — demo speed in km/h, default `26370`.
- `altitude` — demo altitude in km, default `276`.
- `showIcons` — show the vehicle, engine, signal, and data indicators.

This first release uses intentionally deterministic demo values. It does not claim to provide live Starship telemetry and does not make network requests.

## Safety

This is an unsandboxed Quickshell plugin, as are Omarchy third-party plugins generally. Review the code before enabling it. This plugin contains only QML and a manifest; it has no install hooks, shell commands, sudo use, filesystem access, or network access.

## Compatibility

Target: Omarchy Quattro and later.

## License

MIT. See [LICENSE](LICENSE).
