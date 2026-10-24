#!/usr/bin/env bash
# The template's quality gate: every change must pass this before it is committed or uploaded.
# Uses tools from .tools/bin (scripts/install-tools.sh) or, if absent, from PATH (rokit install).
#   bash scripts/check.sh            # integrity checks
#   bash scripts/check.sh --release  # also fail on release blockers (template defaults, missing ids)
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -d .tools/bin ]]; then
	export PATH="$PWD/.tools/bin:$PATH"
fi
DEFS="${ROBLOX_TYPES:-.tools/globalTypes.d.luau}"
if [[ ! -f "$DEFS" ]]; then
	echo "Roblox type definitions not found at $DEFS (run scripts/install-tools.sh or set ROBLOX_TYPES)." >&2
	exit 1
fi

step() {
	echo
	echo "== $1"
}

step "Format (StyLua)"
stylua --check src tests scripts

step "Lint (Selene)"
selene src

step "Sourcemap (Rojo)"
rojo sourcemap default.project.json -o sourcemap.json

step "Types (luau-lsp, strict)"
luau-lsp analyze --defs="$DEFS" --sourcemap=sourcemap.json src

step "Unit tests (Lune)"
lune run tests/run

step "Config gate"
lune run scripts/check-config "$@"

step "Build (Rojo)"
rojo build default.project.json -o build.rbxl

echo
echo "All checks passed."
