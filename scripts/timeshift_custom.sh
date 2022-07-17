#! /usr/bin/env bash

# Run every 6 hours starting from boot time.
[ "$(( $(awk '{print int($1/3600)}' /proc/uptime)%6 ))" -eq 0 ] && \
  timeshift --create --tags H --scripted
