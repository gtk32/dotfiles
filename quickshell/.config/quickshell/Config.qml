pragma Singleton

import QtQuick
import Quickshell

// Gebruikersinstellingen: programma's, locatie en andere persoonlijke keuzes.
Singleton {
    // Terminal voor terminal-apps (Terminal=true in .desktop, netwerk-TUI)
    readonly property var terminal: ["kitty", "-e"]

    // Wat er gestart wordt als je op een bar-module klikt
    readonly property var audioApp: ["kitty", "--class", "pulsemixer",
        "--config", Quickshell.env("HOME") + "/.config/kitty/pulsemixer.conf", "pulsemixer"]
    readonly property var networkApp: terminal.concat(["impala"])   // iwd-TUI
    readonly property var systemMonitor: ["kitty", "--class", "btop",
        "--config", Quickshell.env("HOME") + "/.config/kitty/btop.conf", "btop"]

    // Agenda (rechtsklik op de klok): calcure in maandweergave, leest ~/.calendars/home
    readonly property var calendarApp: ["kitty", "--class", "calcure",
        "--config", Quickshell.env("HOME") + "/.config/kitty/calcure.conf", "calcure"]

    // Weer: API-key en locatie staan in weather.json (niet in git)

    // Aantal balkjes in de CPU-module (cores worden hierover gegroepeerd)
    readonly property int cpuBars: 4

    // Aantal workspaces in de bar
    readonly property int workspaceCount: 9

    // Maximale lengte van de venstertitel naast de workspaces (in tekens)
    readonly property int windowTitleMaxLength: 50
}
