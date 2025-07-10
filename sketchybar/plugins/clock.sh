#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting
LC_TIME=en_US.UTF-8

sketchybar --set "$NAME" label="$(LC_TIME=en_US.UTF-8 date '+%a %d %b   %H:%M')"
