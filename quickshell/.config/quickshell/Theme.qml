pragma Singleton

import QtQuick
import Quickshell

// Kleuren, fonts en maten voor de hele shell.
// Moonfly (zelfde waarden als ~/.config/kitty/moonfly-kitty.conf),
// met de gedimde tekstkleur van One Dark voor lege workspaces e.d.
Singleton {
    // ---------- Kleuren ----------
    readonly property color bg: "#080808"         // background
    readonly property color fg: "#bdbdbd"         // foreground
    readonly property color dim: "#5c6370"        // bewust behouden (One Dark comment-grijs)
    readonly property color accent: "#80a0ff"     // color4  blue
    readonly property color warn: "#ff5d5d"       // color1  red
    readonly property color yellow: "#e3c78a"     // color3  yellow
    readonly property color selection: "#323437"  // color0  grey: randen, scheidingslijnen, selectie
    readonly property color highlight: "#ff5189"  // color9  crimson: popuprand, actieve rij

    // Achtergrond van waarschuwings- en foutmeldingen (donkere tint van yellow/red)
    readonly property color warnBg: "#1f1b12"
    readonly property color errorBg: "#261012"

    readonly property real popupOpacity: 0.92
    readonly property real notificationOpacity: 0.95

    // ---------- Font ----------
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeBody: 13
    readonly property int fontSize: 14
    readonly property int fontSizeLarge: 16
    readonly property int iconSize: 18
    readonly property int iconSizeLarge: 26
    readonly property int launcherFontSize: 18     // zoekbalk + apps in de launcher
    readonly property int powerMenuFontSize: 25    // labels in het powermenu
    readonly property int barIconSize: 18      // losse iconen in de bar (caps, ram, cpu, workspace)
    readonly property int netIconSize: 24      // wifi-glyphs vullen hun vlak minder, dus groter
    readonly property int capsIconSize: 22
    readonly property int weatherIconSize: 24  // weer-glyphs in de weerpopup

    // ---------- Maten ----------
    readonly property int barHeight: 26
    readonly property int borderWidth: 2
    readonly property int popupPadding: 14
    readonly property int rowHeight: 36

    // Nerd Font-glyph uit codepoint
    function g(cp) { return String.fromCodePoint(cp) }
}
