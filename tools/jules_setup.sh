#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.6.2-stable}"
GODOT_ARCHIVE="Godot_v${GODOT_VERSION}_linux.x86_64.zip"
GODOT_BINARY="Godot_v${GODOT_VERSION}_linux.x86_64"
GODOT_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}/${GODOT_ARCHIVE}"
BIN_DIR="${HOME}/.local/bin"
CACHE_DIR="${HOME}/.cache/eidara-jules"

export PATH="${BIN_DIR}:${PATH}"

install_apt_package() {
	local package_name="$1"

	if command -v sudo >/dev/null 2>&1; then
		sudo apt-get update
		sudo apt-get install -y "$package_name"
	else
		apt-get update
		apt-get install -y "$package_name"
	fi
}

ensure_tool() {
	local command_name="$1"
	local package_name="$2"

	if command -v "$command_name" >/dev/null 2>&1; then
		return
	fi

	install_apt_package "$package_name"
}

ensure_tool curl curl
ensure_tool unzip unzip

if [[ "${INSTALL_BLENDER:-0}" == "1" ]] && ! command -v blender >/dev/null 2>&1; then
	install_apt_package blender
fi

if ! command -v godot >/dev/null 2>&1; then
	mkdir -p "$BIN_DIR" "$CACHE_DIR"

	if [[ ! -f "${CACHE_DIR}/${GODOT_ARCHIVE}" ]]; then
		curl -L "$GODOT_URL" -o "${CACHE_DIR}/${GODOT_ARCHIVE}"
	fi

	unzip -o "${CACHE_DIR}/${GODOT_ARCHIVE}" -d "$BIN_DIR"
	chmod +x "${BIN_DIR}/${GODOT_BINARY}"
	ln -sf "${BIN_DIR}/${GODOT_BINARY}" "${BIN_DIR}/godot"
fi

godot --version

if [[ "${RUN_GODOT_IMPORT:-0}" == "1" ]]; then
	godot --headless --path . --editor --quit
fi
