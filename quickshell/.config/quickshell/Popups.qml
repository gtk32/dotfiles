pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Houdt bij welke popup open is (maximaal één tegelijk) en op welk scherm.
Singleton {
    id: root

    // Naam van de open popup ("launcher", "powermenu") of "" als er geen open is
    property string current: ""

    // Scherm waarop de popup opent. Wordt vastgelegd bij het openen,
    // zodat het venster niet meeverhuist als de focus van monitor wisselt.
    property var screen: null

    function focusedScreen() {
        return Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    }

    function open(name) {
        screen = focusedScreen()
        current = name
    }

    function close(name) {
        if (current === name) current = ""
    }

    function toggle(name) {
        if (current === name) close(name)
        else open(name)
    }
}
