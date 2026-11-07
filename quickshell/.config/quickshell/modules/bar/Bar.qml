pragma ComponentBehavior: Bound

// Bar.qml: bar in Omarchy-stijl, één per scherm.
// De data komt uit services/ en wordt door alle schermen gedeeld.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs
import qs.services

Scope {
    id: root

    readonly property int moduleSpacing: 17

    // ---------- Weergave ----------
    function netIcon() {
        if (Network.kind === "eth") return Theme.g(0xf0002)
        if (Network.kind === "wifi") {
            const icons = [0xf092f, 0xf091f, 0xf0922, 0xf0925, 0xf0928]
            return Theme.g(icons[Math.min(4, Math.floor(Network.strength / 20))])
        }
        return Theme.g(0xf092e)
    }

    function batteryIcon(pct, charging) {
        if (charging) return Theme.g(0xf0084)
        const levels = [0xf008e, 0xf007a, 0xf007b, 0xf007c, 0xf007d, 0xf007e, 0xf007f, 0xf0080, 0xf0081, 0xf0082, 0xf0079]
        return Theme.g(levels[Math.min(10, Math.round(pct / 10))])
    }

    function cpuText() {
        // Cores verdeeld over Config.cpuBars groepjes; elk balkje = gemiddelde van zijn groep
        const bars = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
        const cores = SystemStats.cpuCores
        const n = Math.min(Config.cpuBars, cores.length)
        let b = ""
        for (let i = 0; i < n; i++) {
            const group = cores.slice(Math.floor(i * cores.length / n), Math.floor((i + 1) * cores.length / n))
            const avg = group.reduce((a, c) => a + c, 0) / group.length
            b += bars[Math.min(7, Math.floor(avg / 12.5))]
        }
        return b + " " + String(SystemStats.cpuUsage).padStart(2, " ") + "%"
    }

    function ramText() {
        // Totaal afgerond op een even aantal GiB (32 GB-reep toont 32.0G, niet 31.2G)
        const total = Math.ceil(SystemStats.ramTotalGib / 2) * 2
        return SystemStats.ramUsedGib.toFixed(1) + "G/" + total.toFixed(1) + "G"
    }

    // ---------- Services ----------
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    // ---------- Bar (één per scherm) ----------
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            property bool altClock: false

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight
            color: Theme.bg

            // ===== Links: workspaces en titel van het actieve venster =====
            Workspaces {
                id: workspaces
                anchors.left: parent.left
                anchors.leftMargin: 8
                monitor: Hyprland.monitorFor(bar.modelData)
            }

            WindowTitle {
                anchors.left: workspaces.right
                anchors.leftMargin: 10
                monitor: Hyprland.monitorFor(bar.modelData)
            }

            // ===== Midden: klok en weer =====
            // Linksklik = datum/week, rechtsklik = ikhal, hover = maandoverzicht
            BarText {
                id: clockText
                anchors.centerIn: parent
                text: bar.altClock
                    ? Qt.formatDateTime(Time.date, "dd MMMM") + " W" + Time.isoWeek(Time.date) + " " + Qt.formatDateTime(Time.date, "yyyy")
                    : Qt.formatDateTime(Time.date, "dddd HH:mm")
                clickable: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) Quickshell.execDetached(Config.calendarApp)
                    else bar.altClock = !bar.altClock
                }

                CalendarPopup { target: clockText }
            }

            // Weer (hover = 5-daagse voorspelling)
            BarText {
                id: weatherText
                anchors.left: clockText.right
                anchors.leftMargin: 12
                visible: Weather.label !== ""
                text: Weather.label
                color: Theme.dim

                WeatherPopup { target: weatherText }
            }

            // ===== Rechts: caps, tray, netwerk, audio, ram, cpu, batterij =====
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: root.moduleSpacing

                // Caps Lock
                BarItem {
                    visible: CapsLock.active
                    icon: Theme.g(0xf0632)
                    iconSize: Theme.capsIconSize
                    color: Theme.yellow
                }

                Tray {}

                // Netwerk
                BarItem {
                    icon: root.netIcon()
                    iconSize: Theme.netIconSize
                    color: Network.kind === "none" ? Theme.warn : Theme.fg
                    clickable: true
                    onClicked: Quickshell.execDetached(Config.networkApp)
                }

                // Audio (klik = mixer, scroll = volume)
                BarText {
                    id: audio
                    readonly property PwNode sink: Pipewire.defaultAudioSink
                    readonly property bool muted: sink?.audio?.muted ?? false

                    text: (muted ? Theme.g(0xf075f) : Theme.g(0xf028)) + "  " + Math.round((sink?.audio?.volume ?? 0) * 100) + "%"
                    color: muted ? Theme.dim : Theme.fg
                    clickable: true
                    onClicked: Quickshell.execDetached(Config.audioApp)
                    onScrolled: wheel => {
                        const a = audio.sink?.audio
                        if (!a) return
                        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                        a.volume = Math.max(0, Math.min(1.0, a.volume + step))
                    }
                }

                // RAM
                BarItem {
                    visible: SystemStats.ramTotalGib > 0
                    icon: Theme.g(0xf061a)
                    text: root.ramText()
                }

                // CPU (sparkline per core, hover = load per core, klik = btop)
                BarItem {
                    id: cpuItem
                    icon: Theme.g(0xf035b)
                    text: root.cpuText()
                    clickable: true
                    onClicked: Quickshell.execDetached(Config.systemMonitor)

                    CpuPopup { target: cpuItem }
                }

                // Batterij (alleen op laptops)
                BarText {
                    readonly property UPowerDevice dev: UPower.displayDevice
                    readonly property real pct: dev ? dev.percentage * 100 : 0
                    readonly property bool charging: !!dev && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.FullyCharged)

                    visible: !!dev && dev.isLaptopBattery
                    text: root.batteryIcon(pct, charging) + " " + Math.round(pct) + "%"
                    color: pct <= 15 && !charging ? Theme.warn : Theme.fg
                }
            }
        }
    }
}
