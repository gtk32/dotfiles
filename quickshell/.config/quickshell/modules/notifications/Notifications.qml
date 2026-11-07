pragma ComponentBehavior: Bound

// Notifications.qml: notification daemon
// Werkt met notify-send en apps die org.freedesktop.Notifications gebruiken.
// Alles wegklikken: qs ipc call notifications clear
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs

Scope {
    id: root

    readonly property int cardWidth: 400
    readonly property int maxVisible: 5

    // Scherm wordt vastgelegd bij de eerste melding van een reeks, zodat de
    // kaartjes niet van monitor wisselen terwijl ze in beeld zijn.
    property var targetScreen: null

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false      // apps sturen platte tekst
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            if (server.trackedNotifications.values.length === 0)
                root.targetScreen = Popups.focusedScreen()
            n.tracked = true
            // Maximaal maxVisible tegelijk: de oudste verdwijnt
            const vals = server.trackedNotifications.values
            if (vals.length > root.maxVisible) vals[0].expire()
        }
    }

    IpcHandler {
        target: "notifications"
        function clear(): void {
            for (const n of server.trackedNotifications.values.slice()) n.dismiss()
        }
    }

    PanelWindow {
        id: win
        visible: server.trackedNotifications.values.length > 0
        screen: root.targetScreen

        anchors { top: true; right: true }
        margins { top: Theme.barHeight + 10; right: 12 }
        implicitWidth: root.cardWidth
        implicitHeight: Math.max(1, col.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"

        Column {
            id: col
            width: parent.width
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                delegate: NotificationCard {
                    width: col.width
                }
            }
        }
    }
}
