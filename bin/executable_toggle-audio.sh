#!/usr/bin/env bash

SINK1="alsa_output.pci-0000_00_1f.3.analog-stereo"
SINK2="alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1"

current=$(pactl get-default-sink)

if [[ "$current" == "$SINK1" ]]; then
  next="$SINK2"
else
  next="$SINK1"
fi

pactl set-default-sink "$next"

pactl list short sink-inputs | while read -r id _rest; do
  pactl move-sink-input "$id" "$next"
done
