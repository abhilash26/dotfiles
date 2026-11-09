#!/usr/bin/env bash

start_once() {
    local process=${1##*/}

    if ! pgrep -u "$UID" -x "$process" >/dev/null 2>&1; then
        "$@" >/dev/null 2>&1 &
    fi
}

# Wayland specific
systemctl --user restart xdg-desktop-portal.service

# Maintain better power
brightnessctl set 30%
powerprofilesctl set power-saver

# Startup programs
start_once swaybg -i "$HOME/Pictures/wall.jpg" -m fill
start_once nm-applet
start_once waybar
start_once foot --server
