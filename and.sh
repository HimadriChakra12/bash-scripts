#!/bin/bash
echo "🚀 Starting Android Emulator (VNC mode, GPU=guest)..."
emulator -avd test \
  -no-window \
  -no-snapshot-save \
  -no-metrics \
  -gpu guest \
  -qemu -vnc :1
