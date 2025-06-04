#!/bin/bash

# Kill any existing bar
killall -q polybar

# Wait until polybar is dead
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch your bar(s)
polybar example &