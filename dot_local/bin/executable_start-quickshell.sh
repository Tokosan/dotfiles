#!/usr/bin/env bash

pkill quickshell 2>/dev/null || true
nohup quickshell >/dev/null 2>&1 &
