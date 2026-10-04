#!/bin/bash
options="󰤄 Suspend\n󰜉 Reboot\n Logout\n󰐥 Shutdown"
choice=$(echo -e "$options" | walker --dmenu --theme powermenu --placeholder "System..." --width 300 --maxheight 300 --minheight 300)

case "$choice" in
  "󰐥 Shutdown") systemctl poweroff ;;
  "󰜉 Reboot") systemctl reboot ;;
  " Logout") hyprctl dispatch exit ;;
  "󰤄 Suspend") systemctl suspend ;;
esac
