pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs

// Workspaces 1..N. Actief = blokje, bezet = normaal, leeg = gedimd.
Row {
    id: root

    required property var monitor   // HyprlandMonitor van deze bar

    Repeater {
        model: Config.workspaceCount

        delegate: BarText {
            id: ws
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: root.monitor?.activeWorkspace?.id === wsId
            readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === wsId)

            width: 26
            horizontalAlignment: Text.AlignHCenter
            text: active ? Theme.g(0xf14fb) : wsId
            color: active || occupied ? Theme.fg : Theme.dim
            font.pixelSize: active ? Theme.barIconSize : Theme.fontSize

            clickable: true
            onClicked: Quickshell.execDetached(["hyprctl", "dispatch",
                "hl.dsp.focus({ workspace = \"" + ws.wsId + "\" })"])
        }
    }
}
