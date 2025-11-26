#!/bin/zsh

set -euo pipefail

cd "$(dirname "$0")"

BUILD_DIR=".build/xcode"
DIST_DIR=".build/dist"
APP_NAME="ComputerUse.app"

check_dependencies() {
	if ! command -v xcodebuild &>/dev/null; then
		echo "[-] xcodebuild could not be found"
		exit 1
	fi

	if ! command -v xcbeautify &>/dev/null; then
		echo "[-] xcbeautify could not be found, install with: brew install xcbeautify"
		exit 1
	fi
}

prepare_dirs() {
	echo "[*] preparing build directories..."
	mkdir -p "$BUILD_DIR"
	mkdir -p "$DIST_DIR"
}

build_app() {
	echo "[*] building $APP_NAME (Debug)..."
	xcodebuild \
		-workspace ComputerUse.xcworkspace \
		-scheme ComputerUse \
		-configuration Debug \
		-derivedDataPath "$BUILD_DIR" \
		-destination "generic/platform=macOS" \
		build \
		2>&1 | xcbeautify -q
}

copy_app() {
	echo "[*] copying $APP_NAME to $DIST_DIR..."
	cp -R "$BUILD_DIR/Build/Products/Debug/$APP_NAME" "$DIST_DIR/"
	echo "[+] build complete: $DIST_DIR/$APP_NAME"
}

check_dependencies
prepare_dirs
build_app
copy_app
