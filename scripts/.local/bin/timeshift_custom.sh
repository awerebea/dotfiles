#! /usr/bin/env bash

# Run every N hours starting from boot time.
N=3
[ "$(( $(awk '{print int($1/3600)}' /proc/uptime)%N ))" -eq 0 ] && \
  timeshift --create --tags H --scripted
