pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Maakt van een icoonnaam of pad een bruikbare image-source.
    // Absolute paden (bv. kitty's .desktop) gaan als file:// door, anders maakt
    // Quickshell.iconPath() er een ongeldig qrc:-pad van.
    // Bestaan icoon en fallback allebei niet in het thema, dan krijg je "" (geen warning).
    function resolve(icon, fallback) {
        if (!icon) return fallback ? Quickshell.iconPath(fallback, true) : ""
        if (icon.startsWith("/")) return "file://" + icon
        if (icon.startsWith("file:") || icon.startsWith("image:")) return icon
        const found = Quickshell.iconPath(icon, true)
        if (found !== "") return found
        return fallback ? Quickshell.iconPath(fallback, true) : ""
    }
}
