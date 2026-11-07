import QtQuick
import Quickshell.Hyprland
import qs

// Titel van het actieve venster (zoals Waybar's hyprland/window), bv.
// "nvim Bar.qml" of "YouTube — Mozilla Firefox". Leeg op een lege workspace.
BarText {
    id: root

    required property var monitor   // HyprlandMonitor van deze bar

    readonly property var win: Hyprland.activeToplevel
    readonly property string title: win?.title ?? ""

    // Alleen tonen als het venster op de workspace staat die deze monitor laat zien,
    // of in een special workspace (scratchpad: btop, calcure, ...)
    readonly property bool onScreen: {
        const ws = win?.workspace
        if (!ws) return false
        return ws.id < 0 || ws.id === monitor?.activeWorkspace?.id
    }

    visible: onScreen && title !== ""
    text: title.length > Config.windowTitleMaxLength
        ? title.slice(0, Config.windowTitleMaxLength - 1) + "…"
        : title
    font.bold: true
}
