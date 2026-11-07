pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Netwerkstatus uit de kernel, onafhankelijk van NetworkManager, iwd of networkd.
// - /proc/net/route:    welke interface heeft de default route (= de verbinding)
// - /proc/net/wireless: staat die interface erin, dan is het wifi, met signaalsterkte
Singleton {
    id: root

    property string kind: "none"      // eth | wifi | none
    property string iface: ""
    property int strength: 0          // wifi-signaal, 0-100

    function _update() {
        // Default routes (bestemming 00000000), laagste metric eerst
        const defaults = route.text().split("\n").slice(1)
            .map(l => l.trim().split(/\s+/))
            .filter(f => f.length > 6 && f[1] === "00000000")
            .sort((a, b) => Number(a[6]) - Number(b[6]))

        if (defaults.length === 0) {
            kind = "none"
            iface = ""
            return
        }
        iface = defaults[0][0]

        // Kolommen: interface: status link level noise ... (link-kwaliteit is op 70)
        const w = wireless.text().split("\n").slice(2)
            .map(l => l.trim().split(/\s+/))
            .find(f => f[0] === iface + ":")
        if (w) {
            kind = "wifi"
            strength = Math.max(0, Math.min(100, Math.round(parseFloat(w[2]) / 70 * 100)))
        } else {
            kind = "eth"
        }
    }

    FileView {
        id: route
        path: "/proc/net/route"
        onLoaded: root._update()
    }
    FileView {
        id: wireless
        path: "/proc/net/wireless"
        onLoaded: root._update()
    }
    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: { route.reload(); wireless.reload() }
    }
}
