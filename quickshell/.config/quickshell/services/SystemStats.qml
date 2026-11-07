pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU- en geheugengebruik, rechtstreeks uit /proc gelezen (geen subprocessen)
Singleton {
    id: root

    property int cpuUsage: 0          // totaal, 0-100
    property var cpuCores: []         // per core, 0-100
    property real ramUsedGib: 0
    property real ramTotalGib: 0
    property string cpuModel: ""      // bv. "AMD Ryzen 5 5600G"

    property var _prev: []

    function _parseStat(raw) {
        const cur = raw.split("\n").filter(l => l.startsWith("cpu")).map(l => {
            const f = l.trim().split(/\s+/).slice(1, 9).map(Number)
            return { total: f.reduce((a, b) => a + b, 0), idle: f[3] + f[4] }   // idle + iowait
        })
        if (_prev.length === cur.length) {
            const pct = i => {
                const dt = cur[i].total - _prev[i].total
                const di = cur[i].idle - _prev[i].idle
                return dt > 0 ? Math.round(100 * (dt - di) / dt) : 0
            }
            cpuUsage = pct(0)
            cpuCores = cur.slice(1).map((_, i) => pct(i + 1))
        }
        _prev = cur
    }

    function _parseMem(raw) {
        const kb = key => {
            const m = raw.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"))
            return m ? Number(m[1]) : 0
        }
        const gib = 1048576
        const total = kb("MemTotal")
        ramTotalGib = total / gib
        ramUsedGib = (total - kb("MemAvailable")) / gib
    }

    // Processornaam, eenmalig. "with Radeon Graphics" / "6-Core Processor" eraf.
    FileView {
        path: "/proc/cpuinfo"
        onLoaded: {
            const m = text().match(/^model name\s*:\s*(.+)$/m)
            if (m) root.cpuModel = m[1].replace(/\s+(with .*|\d+-Core Processor)$/, "").trim()
        }
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: root._parseStat(text())
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: stat.reload()
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: root._parseMem(text())
    }
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: meminfo.reload()
    }
}
