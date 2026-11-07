pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Hoe vaak elke app via de launcher is gestart (voor "meest gestart" bovenaan).
// Opslag: <Quickshell.stateDir>/launcher-history.json, bv.
//   { "firefox.desktop": { "n": 12, "last": 1762531200000 }, ... }
// Gelezen bij het opstarten, alleen geschreven als je een app start.
Singleton {
    id: root

    property var entries: ({})

    function count(id) {
        return entries[id]?.n ?? 0
    }

    function lastUsed(id) {
        return entries[id]?.last ?? 0
    }

    function record(id) {
        if (!id) return
        const e = Object.assign({}, entries)
        e[id] = { n: count(id) + 1, last: Date.now() }
        entries = e
        file.setText(JSON.stringify(entries, null, 2))
    }

    FileView {
        id: file
        path: Quickshell.stateDir + "/launcher-history.json"
        printErrors: false      // bestaat nog niet tot de eerste app-start
        onLoaded: {
            try {
                root.entries = JSON.parse(text()) || {}
            } catch (e) {
                console.warn("AppHistory: launcher-history.json is ongeldig, begin opnieuw")
                root.entries = {}
            }
        }
    }
}
