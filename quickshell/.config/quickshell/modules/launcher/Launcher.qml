pragma ComponentBehavior: Bound

// Launcher.qml: app-launcher in Omarchy/Walker-stijl
// Aan/uit via: qs ipc call launcher toggle
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.components
import qs.services

Scope {
    id: root

    OverlayPopup {
        id: popup
        name: "launcher"

        content: Item {
            id: view

            property var results: []

            implicitWidth: 612
            implicitHeight: 352

            // Zonder zoekterm: meest gestarte apps bovenaan, de rest alfabetisch.
            // Met zoekterm: eerst op hoe goed de naam past, daarbinnen op gebruik.
            function refresh() {
                const q = input.text.trim().toLowerCase()
                const scored = []
                for (const a of DesktopEntries.applications.values) {
                    if (a.noDisplay) continue
                    const n = a.name.toLowerCase()
                    let s = -1
                    if (q === "") s = AppHistory.count(a.id) > 0 ? 0 : 1
                    else if (n.startsWith(q)) s = 0
                    else if (n.indexOf(q) >= 0) s = 1
                    else if ((a.genericName || "").toLowerCase().indexOf(q) >= 0
                          || (a.keywords || []).join(" ").toLowerCase().indexOf(q) >= 0
                          || (a.comment || "").toLowerCase().indexOf(q) >= 0) s = 2
                    if (s >= 0) scored.push({ app: a, score: s, uses: AppHistory.count(a.id), last: AppHistory.lastUsed(a.id) })
                }
                scored.sort((x, y) => (x.score - y.score)
                                   || (y.uses - x.uses)
                                   || (y.last - x.last)
                                   || x.app.name.localeCompare(y.app.name))
                results = scored.map(e => e.app)
                list.currentIndex = 0
                list.positionViewAtBeginning()
            }

            function launch() {
                const app = results[list.currentIndex]
                if (app) AppHistory.record(app.id)
                popup.close()
                if (!app) return
                if (app.runInTerminal) Quickshell.execDetached(Config.terminal.concat(app.command))
                else app.execute()
            }

            Component.onCompleted: {
                refresh()
                input.forceActiveFocus()
            }

            // De .desktop-bestanden worden pas bij eerste gebruik ingelezen:
            // ververs zodra ze binnen zijn, anders blijft de lijst leeg tot je typt.
            Connections {
                target: DesktopEntries.applications
                function onValuesChanged() { view.refresh() }
            }
            // Idem voor de starttelling (wordt bij eerste gebruik async ingelezen)
            Connections {
                target: AppHistory
                function onEntriesChanged() { if (input.text === "") view.refresh() }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // Zoekbalk
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.rowHeight
                    spacing: 10

                    StyledText {
                        text: Theme.g(0xf002)
                        color: Theme.highlight
                        font.pixelSize: Theme.launcherFontSize
                    }

                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        color: Theme.fg
                        selectionColor: Theme.highlight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.launcherFontSize
                        clip: true

                        onTextChanged: view.refresh()

                        Keys.onPressed: event => {
                            switch (popup.navKey(event)) {
                            case "next": list.incrementCurrentIndex(); break
                            case "prev": list.decrementCurrentIndex(); break
                            case "accept": view.launch(); break
                            }
                        }

                        StyledText {
                            visible: input.text === ""
                            text: "Search..."
                            color: Theme.dim
                            font: input.font
                        }
                    }
                }

                // Scheidingslijn
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.selection
                }

                // Resultaten
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: view.results
                    highlightMoveDuration: 0
                    boundsBehavior: Flickable.StopAtBounds

                    // Geen selectiebalk: de geselecteerde app krijgt alleen roze tekst
                    delegate: Item {
                        id: row
                        required property DesktopEntry modelData
                        required property int index
                        readonly property bool current: ListView.isCurrentItem

                        width: list.width
                        height: 42

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 12

                            IconImage {
                                implicitSize: 28
                                source: Icons.resolve(row.modelData.icon, "application-x-executable")
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: row.modelData.name
                                color: row.current ? Theme.highlight : Theme.fg
                                font.pixelSize: Theme.launcherFontSize
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = row.index
                            onClicked: {
                                list.currentIndex = row.index
                                view.launch()
                            }
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        visible: view.results.length === 0
                        text: "No results"
                        color: Theme.dim
                    }
                }

            }
        }
    }
}
