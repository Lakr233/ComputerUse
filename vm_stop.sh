#!/bin/zsh

set -euo pipefail

cd "$(dirname "$0")"

RUNNER_IMAGE_NAME="cu-test-runner"

echo "[*] stopping and deleting runner image $RUNNER_IMAGE_NAME..."
tart stop "$RUNNER_IMAGE_NAME" || true
sleep 1
tart delete "$RUNNER_IMAGE_NAME" || true
echo "[*] cleanup done"
