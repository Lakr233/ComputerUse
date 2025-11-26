#!/bin/zsh

set -euo pipefail

cd "$(dirname "$0")"

RUNNER_IMAGE_NAME="cu-test-runner"
RUNNER_USERNAME="admin"
RUNNER_PASSWORD="admin"

LOCAL_APP_PATH=".build/dist/ComputerUse.app"
REMOTE_APP_PATH="/Applications/ComputerUse.app"

RUNNER_IP=$(tart ip "$RUNNER_IMAGE_NAME" 2>/dev/null || true)

if [ -z "$RUNNER_IP" ]; then
	echo "[-] Error: VM '$RUNNER_IMAGE_NAME' is not running. Please run ./vm_start.sh first."
	exit 1
fi

echo "[*] runner ip address: $RUNNER_IP"

function execute_runner_command() {
	local CMD="$1"
	echo "[*] executing on runner: $CMD"
	sshpass -p "$RUNNER_PASSWORD" \
		ssh -o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o PreferredAuthentications=password \
		-t \
		"$RUNNER_USERNAME@$RUNNER_IP" "source ~/.zprofile && $CMD"
}

function execute_runner_upload() {
	local SRC="$1"
	local DEST="$2"
	echo "[*] uploading $SRC to $DEST"
	sshpass -p "$RUNNER_PASSWORD" \
		scp -o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o PreferredAuthentications=password \
		-r "$SRC" \
		"$RUNNER_USERNAME@$RUNNER_IP:$DEST"
}

function upload_app() {
	echo "[*] uploading $LOCAL_APP_PATH to $REMOTE_APP_PATH..."
	execute_runner_command "sudo pkill -9 ComputerUse" || true
	execute_runner_command "rm -rf \"$REMOTE_APP_PATH\"" || true
	execute_runner_upload "$LOCAL_APP_PATH" "$REMOTE_APP_PATH"
	execute_runner_command "sudo xattr -cr \"$REMOTE_APP_PATH\""
}

function start_app() {
	echo "[*] starting app at $REMOTE_APP_PATH..."
	execute_runner_command "open '$REMOTE_APP_PATH'"
}

function drop_to_shell() {
	echo "[*] dropping to interactive shell on runner..."
	echo "[*] type 'exit' to disconnect"
	sshpass -p "$RUNNER_PASSWORD" \
		ssh -o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o PreferredAuthentications=password \
		-t \
		"$RUNNER_USERNAME@$RUNNER_IP"
}

./run_build.sh
upload_app
start_app

echo ""
echo "[*] app started!"
