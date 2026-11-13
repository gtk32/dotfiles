pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.components

// Tray-menu in Moonfly-stijl (vervangt het witte Qt-standaardmenu).
// Gebruik: TrayMenu { id: m; target: item; menu: item.menu }  en dan m.toggle().
// Submenu's openen in hetzelfde venster; bovenaan staat dan een "terug"-rij.
PopupWindow {
    id: root

    required property Item target
    required property var menu          // QsMenuHandle van het tray-item

    property var stack: []              // pad van geopende submenu-entries
    readonly property var current: stack.length > 0 ? stack[stack.length - 1] : menu
    property double closedAt: 0
    property real contentW: 0           // breedte van de breedste rij

    readonly property int padding: 6
    readonly property int rowH: 28

    function toggle() {
        // Klik buiten het menu sluit het via de focus grab; negeer de heropening
        // als dezelfde klik op het tray-icoon komt.
        if (visible) { visible = false; return }
        if (Date.now() - closedAt < 250) return
        stack = []
        visible = true
    }

    anchor.item: target
    anchor.rect.x: 0
    anchor.rect.y: 0
    anchor.rect.width: target.width
    anchor.rect.height: target.height + 6
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide

    // Breedste rij bepalen. Niet via column.implicitWidth: de rijen volgen de kolombreedte,
    // en dan blijft de breedte hangen op het minimum.
    function measure() {
        let w = backRow.visible ? backRow.implicitWidth : 0
        for (let i = 0; i < rows.count; i++) {
            const it = rows.itemAt(i)
            if (it) w = Math.max(w, it.implicitWidth)
        }
        contentW = w
    }
    onStackChanged: Qt.callLater(measure)

    implicitWidth: Math.max(180, contentW + 2 * padding + 2 * Theme.borderWidth)
    implicitHeight: column.implicitHeight + 2 * padding + 2 * Theme.borderWidth
    color: "transparent"
    visible: false

    onVisibleChanged: {
        if (!visible) closedAt = Date.now()
        // Grab pas aanzetten als het venster bestaat, anders pakt Hyprland hem niet op
        Qt.callLater(() => grab.active = root.visible)
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: false
        onCleared: root.visible = false
    }

    QsMenuOpener {
        id: opener
        menu: root.current
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.selection
        border.width: Theme.borderWidth

        Column {
            id: column
            x: root.padding + Theme.borderWidth
            y: root.padding + Theme.borderWidth
            width: parent.width - 2 * (root.padding + Theme.borderWidth)

            // Terug-rij in een submenu
            Rectangle {
                id: backRow
                visible: root.stack.length > 0
                width: parent.width
                height: visible ? root.rowH : 0
                implicitWidth: backText.implicitWidth + 24
                color: backArea.containsMouse ? Theme.selection : "transparent"

                StyledText {
                    id: backText
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "‹  " + (root.stack.length > 0 ? root.stack[root.stack.length - 1].text : "")
                    color: Theme.accent
                    font.pixelSize: Theme.fontSizeBody
                }
                MouseArea {
                    id: backArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.stack = root.stack.slice(0, -1)
                }
            }

            Repeater {
                id: rows
                model: opener.children
                onItemAdded: Qt.callLater(root.measure)
                onItemRemoved: Qt.callLater(root.measure)

                delegate: Item {
                    id: row
                    required property var modelData

                    readonly property bool sep: modelData.isSeparator
                    readonly property bool checkable: modelData.buttonType !== QsMenuButtonType.None
                    readonly property bool checked: modelData.checkState === Qt.Checked

                    width: column.width
                    height: sep ? 9 : root.rowH
                    implicitWidth: sep ? 0 : 10 + 16 + 8 + label.implicitWidth + 16 + 14 + 10

                    // Scheidingslijn
                    Rectangle {
                        visible: row.sep
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        height: 1
                        color: Theme.selection
                    }

                    // Gewone rij
                    Rectangle {
                        visible: !row.sep
                        anchors.fill: parent
                        color: area.containsMouse && row.modelData.enabled ? Theme.selection : "transparent"

                        // Vinkje/bolletje of icoon
                        Item {
                            id: slot
                            x: 10
                            width: 16
                            height: 16
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                anchors.centerIn: parent
                                visible: row.checkable && row.checked
                                text: row.modelData.buttonType === QsMenuButtonType.RadioButton ? "●" : "✓"
                                color: Theme.accent
                                font.pixelSize: Theme.fontSizeBody
                            }
                            IconImage {
                                anchors.fill: parent
                                visible: !row.checkable && row.modelData.icon !== ""
                                source: row.modelData.icon
                            }
                        }

                        StyledText {
                            id: label
                            anchors.left: slot.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.text
                            color: row.modelData.enabled ? Theme.fg : Theme.dim
                            font.pixelSize: Theme.fontSizeBody
                        }

                        StyledText {
                            visible: row.modelData.hasChildren
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "›"
                            color: Theme.dim
                            font.pixelSize: Theme.fontSizeBody
                        }

                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!row.modelData.enabled) return
                                if (row.modelData.hasChildren) {
                                    root.stack = root.stack.concat([row.modelData])
                                } else {
                                    row.modelData.triggered()
                                    root.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
