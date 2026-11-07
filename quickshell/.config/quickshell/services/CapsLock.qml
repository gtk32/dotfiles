pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Caps Lock-status via de toetsenbord-LEDs in /sys/class/leds (geen hyprctl-polling).
// Bij meerdere toetsenborden telt "aan" als één van de LEDs brandt.
Singleton {
    id: root

    property bool active: false
    property var ledPaths: []

    function _recompute() {
        active = leds.instances.some(f => Number((f.text() || "0").trim()) > 0)
    }

    // Zoek de capslock-LEDs. Opnieuw elke 10 s, voor in- en uitgeplugde toetsenborden.
    Process {
        id: scan
        command: ["find", "/sys/class/leds", "-maxdepth", "1", "-name", "*::capslock"]
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = text.split("\n").filter(p => p !== "").sort()
                if (JSON.stringify(paths) !== JSON.stringify(root.ledPaths)) root.ledPaths = paths
            }
        }
    }
    Timer {
        interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: scan.running = true
    }

    Variants {
        id: leds
        model: root.ledPaths

        FileView {
            required property string modelData
            path: modelData + "/brightness"
            printErrors: false
            onLoaded: root._recompute()
        }
    }

    // sysfs-waarden geven geen inotify-events, dus licht pollen (alleen een bestandsread)
    Timer {
        interval: 300; running: root.ledPaths.length > 0; repeat: true
        onTriggered: leds.instances.forEach(f => f.reload())
    }
}
