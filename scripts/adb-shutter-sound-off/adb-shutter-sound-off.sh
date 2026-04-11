#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  if pgrep -x adb >/dev/null 2>&1; then
    adb kill-server >/dev/null 2>&1 || true
    echo "ADB server stopped."
  else
    echo "ADB server was already stopped."
  fi
}

wait_for_authorized_device() {
  echo "Waiting for an authorized Android device..."
  echo "Approve the USB debugging prompt on the phone if it appears."

  adb start-server >/dev/null
  adb wait-for-device

  until adb shell true >/dev/null 2>&1; do
    sleep 1
  done
}

trap cleanup EXIT

wait_for_authorized_device
adb shell settings put system csc_pref_camera_forced_shuttersound_key 0
echo "Disabled forced camera shutter sound."
