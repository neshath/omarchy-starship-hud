#!/usr/bin/env bash
set -euo pipefail

THEME_URL="https://github.com/neshath/omarchy-starship-theme"
PLUGIN_URL="https://github.com/neshath/omarchy-starship-hud.git"
PLUGIN_ID="neshath.starship-hud"

command -v omarchy >/dev/null 2>&1 || {
  echo "Error: the omarchy command was not found." >&2
  exit 1
}

printf '%s\n' "Installing the Starship visual theme..."
omarchy theme install "$THEME_URL"

printf '%s\n' "Installing and enabling the Starship HUD plugin..."
omarchy plugin add "$PLUGIN_URL" --enable --yes

printf '%s\n' "Moving the Omarchy bar to the bottom..."
omarchy bar position bottom

printf '%s\n' "Placing the Starship HUD in the center section..."
omarchy bar move "$PLUGIN_ID" --section center --index 0

printf '\n%s\n' "Starship theme and HUD installed successfully."
