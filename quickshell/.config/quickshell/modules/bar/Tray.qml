pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

// Systeemvak, altijd zichtbaar.
// Links = activeren, midden = secundair, rechts = menu.
Row {
    id: root

    spacing: 10
    height: Theme.barHeight
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: trayArea
            required property SystemTrayItem modelData

            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            IconImage {
                anchors.fill: parent
                source: trayArea.modelData.icon
            }
            QsMenuAnchor {
                id: trayMenu
                menu: trayArea.modelData.menu
                anchor.item: trayArea
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) trayArea.modelData.activate()
                else if (mouse.button === Qt.MiddleButton) trayArea.modelData.secondaryActivate()
                else if (trayArea.modelData.hasMenu) trayMenu.open()
            }
        }
    }
}
