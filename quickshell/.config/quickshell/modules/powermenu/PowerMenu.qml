pragma ComponentBehavior: Bound

// PowerMenu.qml: power menu in Omarchy/Walker-stijl
// Aan/uit via: qs ipc call powermenu toggle
import QtQuick
import Quickshell
import qs
import qs.components

Scope {
    id: root

    // Van boven naar onder
    readonly property var items: [
        { icon: 0xf04b2, label: "Suspend",  cmd: ["systemctl", "suspend"] },
        { icon: 0xf0709, label: "Reboot",   cmd: ["systemctl", "reboot"] },
        // Logout: sessie beëindigen, greetd/tuigreet verschijnt weer.
        // Valt terug op Hyprland's eigen exit als er geen sessie-id is.
        { icon: 0xf0343, label: "Logout",   cmd: ["sh", "-c", "loginctl terminate-session \"$XDG_SESSION_ID\" || hyprctl dispatch exit"] },
        { icon: 0xf0425, label: "Shutdown", cmd: ["systemctl", "poweroff"] }
    ]

    OverlayPopup {
        id: popup
        name: "powermenu"

        content: Item {
            id: view

            property int sel: 0

            implicitWidth: 320
            implicitHeight: col.implicitHeight
            focus: true

            function run(i) {
                popup.close()
                Quickshell.execDetached(root.items[i].cmd)
            }

            function move(delta) {
                sel = (sel + delta + root.items.length) % root.items.length
            }

            Component.onCompleted: forceActiveFocus()

            Keys.onPressed: event => {
                switch (popup.navKey(event)) {
                case "next": view.move(1); break
                case "prev": view.move(-1); break
                case "accept": view.run(view.sel); break
                }
            }

            Column {
                id: col
                width: parent.width

                Repeater {
                    model: root.items

                    delegate: Item {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool current: view.sel === index

                        width: col.width
                        height: 52

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 16

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 48
                                horizontalAlignment: Text.AlignHCenter
                                text: Theme.g(row.modelData.icon)
                                color: row.current ? Theme.highlight : Theme.fg
                                font.pixelSize: Theme.powerMenuFontSize + 16  // MDI-glyph oogt kleiner dan tekst
                            }
                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: row.modelData.label
                                color: row.current ? Theme.highlight : Theme.fg
                                font.pixelSize: Theme.powerMenuFontSize
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: view.sel = row.index
                            onClicked: view.run(row.index)
                        }
                    }
                }
            }
        }
    }
}
