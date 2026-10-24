#!/usr/bin/env bash
# Installs the pinned toolchain (versions read from rokit.toml) into .tools/ for Linux x86_64.
# CI uses this; locally you can use it too, or run `rokit install` (any OS) and skip it.
#   bash scripts/install-tools.sh
set -euo pipefail
cd "$(dirname "$0")/.."

TOOLS_DIR=".tools"
BIN="$TOOLS_DIR/bin"
mkdir -p "$BIN"

version() {
	# rokit.toml lines look like: rojo = "rojo-rbx/rojo@7.7.1"
	grep -E "^$1 *=" rokit.toml | sed -E 's/.*@([^"]+)".*/\1/'
}

fetch() {
	local name="$1" url="$2"
	if [[ -x "$BIN/$name" && -f "$TOOLS_DIR/$name.version" && "$(cat "$TOOLS_DIR/$name.version")" == "$url" ]]; then
		echo "ok        $name (cached)"
		return
	fi
	local tmp
	tmp="$(mktemp -d)"
	curl -sSfL --retry 3 -o "$tmp/tool.zip" "$url"
	unzip -q -o "$tmp/tool.zip" -d "$tmp/out"
	local found
	found="$(find "$tmp/out" -type f -name "$name" | head -n 1)"
	if [[ -z "$found" ]]; then
		echo "error: $name not found in $url" >&2
		exit 1
	fi
	install -m 0755 "$found" "$BIN/$name"
	echo "$url" > "$TOOLS_DIR/$name.version"
	rm -rf "$tmp"
	echo "installed $name from $url"
}

ROJO="$(version rojo)"
SELENE="$(version selene)"
STYLUA="$(version stylua)"
LUNE="$(version lune)"
LUAU_LSP="$(version luau-lsp)"
WALLY="$(version wally)"

fetch rojo "https://github.com/rojo-rbx/rojo/releases/download/v$ROJO/rojo-$ROJO-linux-x86_64.zip"
fetch selene "https://github.com/Kampfkarren/selene/releases/download/$SELENE/selene-$SELENE-linux.zip"
fetch stylua "https://github.com/JohnnyMorganz/StyLua/releases/download/v$STYLUA/stylua-linux-x86_64.zip"
fetch lune "https://github.com/lune-org/lune/releases/download/v$LUNE/lune-$LUNE-linux-x86_64.zip"
fetch luau-lsp "https://github.com/JohnnyMorganz/luau-lsp/releases/download/$LUAU_LSP/luau-lsp-linux-x86_64.zip"
fetch wally "https://github.com/UpliftGames/wally/releases/download/v$WALLY/wally-v$WALLY-linux.zip"

# Roblox API type definitions, pinned to the same luau-lsp release.
DEFS_URL="https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/$LUAU_LSP/scripts/globalTypes.d.luau"
if [[ ! -f "$TOOLS_DIR/globalTypes.d.luau" || "$(cat "$TOOLS_DIR/defs.version" 2>/dev/null)" != "$DEFS_URL" ]]; then
	curl -sSfL --retry 3 -o "$TOOLS_DIR/globalTypes.d.luau" "$DEFS_URL"
	echo "$DEFS_URL" > "$TOOLS_DIR/defs.version"
	echo "installed Roblox type definitions"
fi

echo "Tools ready in $BIN (add it to PATH, or run scripts/check.sh which does)."
