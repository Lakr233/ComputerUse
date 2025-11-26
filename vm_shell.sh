#!/bin/zsh

set -euo pipefail

cd "$(dirname "$0")"

RUNNER_IMAGE_NAME="cu-test-runner"
RUNNER_USERNAME="admin"
RUNNER_PASSWORD="admin"

RUNNER_IP=$(tart ip "$RUNNER_IMAGE_NAME" 2>/dev/null || true)

if [ -z "$RUNNER_IP" ]; then
	echo "[-] Error: VM '$RUNNER_IMAGE_NAME' is not running. Please run ./vm_start.sh first."
	exit 1
fi

echo "[*] runner ip address: $RUNNER_IP"

echo "[*] dropping to interactive shell on runner..."
echo "[*] type 'exit' to disconnect"
sshpass -p "$RUNNER_PASSWORD" \
	ssh -o StrictHostKeyChecking=no \
	-o UserKnownHostsFile=/dev/null \
	-o PreferredAuthentications=password \
	-t \
	"$RUNNER_USERNAME@$RUNNER_IP"
