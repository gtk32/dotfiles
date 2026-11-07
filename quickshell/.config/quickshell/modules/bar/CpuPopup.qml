pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.components
import qs.services

// Hover-venster bij de CPU-module: processornaam, totaal en load per core.
HoverPopup {
    id: root

    function loadColor(p) {
        return p >= 85 ? Theme.warn : (p >= 60 ? Theme.yellow : Theme.fg)
    }

    // Kop: naam links, totaal rechts
    Item {
        width: grid.width
        height: header.implicitHeight

        StyledText {
            id: header
            anchors.left: parent.left
            anchors.right: total.left
            anchors.rightMargin: 12
            text: Theme.g(0xf035b) + "  " + (SystemStats.cpuModel || "CPU")
            font.bold: true
            elide: Text.ElideRight
        }
        StyledText {
            id: total
            anchors.right: parent.right
            text: SystemStats.cpuUsage + "%"
            color: root.loadColor(SystemStats.cpuUsage)
            font.bold: true
        }
    }

    Rectangle {
        width: grid.width
        height: 1
        color: Theme.selection
    }

    // Cores in twee kolommen, van boven naar onder genummerd
    Grid {
        id: grid
        columns: 2
        rows: Math.ceil(SystemStats.cpuCores.length / 2)
        flow: Grid.TopToBottom
        columnSpacing: 24
        rowSpacing: 5

        Repeater {
            // Aantal cores als model: delegates blijven staan, alleen de waarden veranderen
            model: SystemStats.cpuCores.length

            delegate: Row {
                id: core
                required property int index
                readonly property int pct: SystemStats.cpuCores[index] ?? 0

                spacing: 8

                StyledText {
                    width: 26
                    anchors.verticalCenter: parent.verticalCenter
                    text: "C" + core.index
                    color: Theme.dim
                    font.pixelSize: Theme.fontSizeSmall
                }

                // Balkje
                Rectangle {
                    width: 90
                    height: 6
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.selection

                    Rectangle {
                        width: parent.width * Math.min(100, core.pct) / 100
                        height: parent.height
                        radius: parent.radius
                        color: root.loadColor(core.pct)
                    }
                }

                StyledText {
                    width: 34
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: core.pct + "%"
                    color: root.loadColor(core.pct)
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}
