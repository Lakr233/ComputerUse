#!/bin/zsh

set -euo pipefail

cd "$(dirname "$0")"

./vm_stop.sh || true

TART_IMAGE="macos-tahoe-xcode-tccutil"
RUNNER_IMAGE_NAME="cu-test-runner"

prepare_image() {
	if echo $(tart list || true) | grep -q "$TART_IMAGE"; then
		echo "[*] base image $TART_IMAGE exists"
	else
		echo "[*] base image $TART_IMAGE does not exist, pulling..."
		tart pull "$TART_IMAGE"
	fi

	if echo $(tart list || true) | grep -q "$RUNNER_IMAGE_NAME"; then
		echo "[*] runner image $RUNNER_IMAGE_NAME already exists"
	else
		echo "[*] creating runner image $RUNNER_IMAGE_NAME..."
		tart clone "$TART_IMAGE" "$RUNNER_IMAGE_NAME"
	fi
}

start_vm() {
	echo "[*] checking runner image status..."

	RUNNER_IP=$(tart ip "$RUNNER_IMAGE_NAME" 2>/dev/null || true)

	if [ -n "$RUNNER_IP" ]; then
		echo "[*] runner is already running at $RUNNER_IP"
		return
	fi

	echo "[*] starting runner image..."
	tart run "$RUNNER_IMAGE_NAME" \
		--no-audio \
		--no-clipboard \
		& # detach

	echo "[*] waiting for runner image to start..."
	RUNNER_BOOT_ATTEMPTS=0
	while [ -z "$RUNNER_IP" ] && [ $RUNNER_BOOT_ATTEMPTS -lt 30 ]; do
		sleep 2
		echo "[*] checking for runner ip address..."
		RUNNER_BOOT_ATTEMPTS=$((RUNNER_BOOT_ATTEMPTS + 1))
		RUNNER_IP=$(tart ip "$RUNNER_IMAGE_NAME" 2>/dev/null || true)
	done

	if [ -z "$RUNNER_IP" ]; then
		echo "[-] Error: Failed to get IP address for VM '$RUNNER_IMAGE_NAME' after 30 attempts"
		echo "[-] VM may have failed to start properly"
		exit 1
	fi

	echo "[*] runner ip address: $RUNNER_IP"

	RUNNER_USERNAME="admin"
	RUNNER_PASSWORD="admin"

	while [ $RUNNER_BOOT_ATTEMPTS -lt 60 ]; do
		echo "[*] checking for ssh connectivity to $RUNNER_IP..."
		if sshpass -p "$RUNNER_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o ConnectTimeout=2 "$RUNNER_USERNAME@$RUNNER_IP" "echo hello"; then
			echo "[*] ssh connectivity to $RUNNER_IP established"
			break
		fi
		echo "[*] ssh connectivity to $RUNNER_IP not yet established, waiting..."
		sleep 2
		RUNNER_BOOT_ATTEMPTS=$((RUNNER_BOOT_ATTEMPTS + 1))
	done

	if [ $RUNNER_BOOT_ATTEMPTS -ge 60 ]; then
		echo "[-] Error: Failed to establish SSH connectivity to $RUNNER_IP after 60 attempts"
		exit 1
	fi
}

prepare_image
start_vm
