#!/usr/bin/env bash
# Idempotent Cloud Agent setup for this Roblox / Luau project.
# Installs the Rokit toolchain manager, the pinned tools from rokit.toml
# (Rojo, Wally, StyLua, Selene, Lune, luau-lsp), and generates the artifacts
# needed for type-checking (Roblox global type defs + Rojo sourcemap).
set -euo pipefail

ROKIT_VERSION="1.2.0"
ROKIT_BIN="$HOME/.rokit/bin"

log() { printf '\n[install] %s\n' "$*"; }

# A GitHub token lifts the anonymous API rate limit that Rokit hits when it
# resolves and downloads tools. Use whatever the environment provides; never
# hard-code a token.
GH_TOKEN_VALUE="${GITHUB_TOKEN:-${GITHUB_PAT:-${GH_TOKEN:-}}}"
if [ -z "$GH_TOKEN_VALUE" ] && command -v gh >/dev/null 2>&1; then
	GH_TOKEN_VALUE="$(gh auth token 2>/dev/null || true)"
fi
export GITHUB_PAT="$GH_TOKEN_VALUE"

# 1. Install Rokit itself if it is not already present.
if [ ! -x "$ROKIT_BIN/rokit" ]; then
	log "Installing Rokit $ROKIT_VERSION"
	curl --proto '=https' --tlsv1.2 -sSf \
		https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash -s -- "$ROKIT_VERSION"
else
	log "Rokit already installed: $("$ROKIT_BIN/rokit" --version)"
fi

export PATH="$ROKIT_BIN:$PATH"

# 2. Authenticate Rokit with GitHub when a token is available (best effort).
if [ -n "$GH_TOKEN_VALUE" ]; then
	rokit authenticate github --token "$GH_TOKEN_VALUE" --skip-verify >/dev/null 2>&1 || true
fi

# 3. Trust and install the tools pinned in rokit.toml. Trusting is required for
#    non-interactive installs.
log "Trusting and installing project tools"
rokit trust \
	rojo-rbx/rojo \
	UpliftGames/wally \
	JohnnyMorganz/StyLua \
	Kampfkarren/selene \
	lune-org/lune \
	JohnnyMorganz/luau-lsp >/dev/null 2>&1 || true
rokit install --no-trust-check 2>/dev/null || rokit install

# 4. Install Wally dependencies when any are declared.
if [ -f wally.toml ] && grep -Eq '^\s*[A-Za-z0-9_-]+\s*=' <(sed -n '/^\[dependencies\]/,/^\[/p' wally.toml); then
	log "Installing Wally packages"
	wally install
else
	log "No Wally dependencies declared; skipping wally install"
fi

# 5. Fetch Roblox global type definitions used by luau-lsp for type-checking.
log "Fetching Roblox global type definitions"
curl --proto '=https' --tlsv1.2 -sSf \
	https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau \
	-o globalTypes.d.luau

# 6. Generate a Rojo sourcemap so luau-lsp can resolve instance-based requires.
log "Generating Rojo sourcemap"
rojo sourcemap default.project.json --output sourcemap.json

log "Setup complete. Tools available:"
rokit list || true
