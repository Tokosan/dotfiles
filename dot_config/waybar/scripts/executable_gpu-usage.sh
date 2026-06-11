#!/bin/bash

if command -v nvidia-smi &> /dev/null; then
    USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}')
elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
    USAGE=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
else
    USAGE=0
fi

# Round to nearest 5 to match your CSS classes (p5, p10, p15...)
CLASS_VAL=$(( (USAGE + 2) / 5 * 5 ))

# Output JSON with the class added
echo "{\"text\": \"$USAGE%\", \"tooltip\": \"GPU Usage: $USAGE%\", \"percentage\": $USAGE, \"class\": \"p$CLASS_VAL\"}"
