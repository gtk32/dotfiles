pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

// Systeemvak, altijd zichtbaar.
// Links = activeren, midden = secundair, rechts = menu (TrayMenu, in thema).
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
            TrayMenu {
                id: trayMenu
                target: trayArea
                menu: trayArea.modelData.menu
            }
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    // Sommige apps hebben alleen een menu: dan opent linksklik dat menu
                    if (trayArea.modelData.onlyMenu && trayArea.modelData.hasMenu) trayMenu.toggle()
                    else trayArea.modelData.activate()
                } else if (mouse.button === Qt.MiddleButton) trayArea.modelData.secondaryActivate()
                else if (trayArea.modelData.hasMenu) trayMenu.toggle()
            }
        }
    }
}
