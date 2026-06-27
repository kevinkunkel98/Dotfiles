#!/bin/bash

status=$(playerctl status 2>/dev/null)

if [ -z "$status" ] || [ "$status" = "Stopped" ]; then
    prompt="Nothing playing"
else
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    if [ -n "$artist" ]; then
        prompt="$artist - $title"
    else
        prompt="$title"
    fi
fi

if [ "$status" = "Playing" ]; then
    toggle="⏸  Pause"
else
    toggle="▶  Play"
fi

chosen=$(printf "⏮  Previous\n$toggle\n⏭  Next" | rofi -dmenu \
    -p "$prompt" \
    -no-custom \
    -theme ~/.config/rofi/themes/rofi-media.rasi)

case "$chosen" in
    "⏮  Previous")  playerctl previous ;;
    "⏸  Pause")     playerctl pause ;;
    "▶  Play")      playerctl play ;;
    "⏭  Next")      playerctl next ;;
esac
