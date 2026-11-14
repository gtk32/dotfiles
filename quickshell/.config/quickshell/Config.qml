pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Gebruikersinstellingen: programma's en andere persoonlijke keuzes.
//
// De waarden hieronder zijn de defaults. Wie ze wil aanpassen zonder deze
// map te forken zet alleen de afwijkende sleutels in ~/.config/styx/shell.json,
// bijvoorbeeld {"cpuBars": 8, "systemMonitor": ["kitty", "btop"]}.
// Onbekende sleutels en waarden van het verkeerde type worden genegeerd; het
// bestand wordt bij wijziging opnieuw geladen. Een lege lijst ([]) schakelt
// de klik-actie uit.
Singleton {
    id: root

    // Terminal voor terminal-apps (Terminal=true in .desktop)
    property var terminal: ["kitty", "-e"]

    // Wat er gestart wordt als je op een bar-module klikt. De --class bepaalt
    // welke Hyprland-windowregel (special:magic) het venster krijgt.
    property var audioApp: ["kitty", "--class", "wiremix", "-o", "font_size=18", "wiremix"]
    property var systemMonitor: ["kitty", "--class", "btop", "-o", "font_size=18", "btop"]

    // Nog geen vervanger: klik op netwerk en rechtsklik op de klok doen niets.
    property var networkApp: []
    property var calendarApp: []

    // Weer: API-key en locatie staan in ~/.config/styx/weather.json (niet in git)

    // Aantal balkjes in de CPU-module (cores worden hierover gegroepeerd)
    property int cpuBars: 4

    // Aantal workspaces in de bar
    property int workspaceCount: 9

    // Maximale lengte van de venstertitel naast de workspaces (in tekens)
    property int windowTitleMaxLength: 50

    // Momentopname van de defaults hierboven (bewust geen binding, anders
    // verandert hij mee met de waarden uit shell.json).
    property var _defaults: null
    readonly property var _keys: ["terminal", "audioApp", "systemMonitor", "networkApp",
        "calendarApp", "cpuBars", "workspaceCount", "windowTitleMaxLength"]

    function _isCmd(v) {
        return Array.isArray(v) && v.every(x => typeof x === "string")
    }

    function _apply(raw) {
        let s = {}
        try { s = JSON.parse(raw) } catch (e) {
            console.warn("Config: shell.json is geen geldige JSON:", e)
        }
        if (_defaults === null) {
            const d = {}
            for (const k of _keys) d[k] = root[k]
            _defaults = d
        }
        for (const k of _keys) {
            const d = _defaults[k]
            const ok = (k in s) && (typeof d === "number" ? typeof s[k] === "number" : _isCmd(s[k]))
            root[k] = ok ? s[k] : d
        }
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/styx/shell.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root._apply(text())
        onLoadFailed: root._apply("{}")
    }
}
