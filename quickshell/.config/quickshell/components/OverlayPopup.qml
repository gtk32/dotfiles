pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

// Gedeelde basis voor launcher en powermenu:
// - overlay-venster midden op het scherm dat bij openen gefocust was
// - IPC: qs ipc call <name> toggle|open|close
// - sluit bij Escape of bij een klik ernaast
// - het venster wordt pas aangemaakt bij openen (LazyLoader) en opgeruimd bij sluiten
// De grootte volgt de implicitWidth/implicitHeight van `content` plus padding.
Scope {
    id: root

    required property string name
    property Component content

    readonly property bool shown: Popups.current === name

    function close() { Popups.close(name) }

    // Gedeelde toetsnavigatie. Escape sluit de popup zelf.
    // Geeft "next", "prev", "accept" of "" terug.
    function navKey(event) {
        const ctrl = event.modifiers & Qt.ControlModifier
        const k = event.key
        let action = ""
        if (k === Qt.Key_Escape) close()
        else if (k === Qt.Key_Down || k === Qt.Key_Tab || (ctrl && (k === Qt.Key_N || k === Qt.Key_J))) action = "next"
        else if (k === Qt.Key_Up || k === Qt.Key_Backtab || (ctrl && (k === Qt.Key_P || k === Qt.Key_K))) action = "prev"
        else if (k === Qt.Key_Return || k === Qt.Key_Enter) action = "accept"
        else return ""
        event.accepted = true
        return action
    }

    IpcHandler {
        target: root.name
        function toggle(): void { Popups.toggle(root.name) }
        function open(): void { Popups.open(root.name) }
        function close(): void { Popups.close(root.name) }
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            id: win
            screen: Popups.screen

            implicitWidth: loader.implicitWidth + 2 * Theme.popupPadding
            implicitHeight: loader.implicitHeight + 2 * Theme.popupPadding
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell-" + root.name

            HyprlandFocusGrab {
                windows: [win]
                active: true
                onCleared: root.close()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Theme.bg, Theme.popupOpacity)
                border.color: Theme.highlight
                border.width: Theme.borderWidth

                Loader {
                    id: loader
                    anchors.fill: parent
                    anchors.margins: Theme.popupPadding
                    focus: true
                    sourceComponent: root.content
                }
            }
        }
    }
}
