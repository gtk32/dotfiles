import QtQuick
import Quickshell
import qs

// Klein venster onder een bar-item, zichtbaar zolang de muis erboven hangt.
// Gebruik: zet hem als kind in een item met een `hovered`-property (bv. BarItem):
//   BarItem { id: x; HoverPopup { target: x; StyledText { text: "..." } } }
// De inhoud komt in een Column; de venstergrootte volgt die automatisch.
PopupWindow {
    id: root

    required property Item target
    property int showDelay: 300      // ms boven het item voordat de popup verschijnt
    property int padding: 10
    property int gap: 6              // ruimte tussen bar en popup

    default property alias content: column.data
    readonly property bool hovered: target?.hovered ?? false

    anchor.item: target
    anchor.rect.x: 0
    anchor.rect.y: 0
    anchor.rect.width: target.width
    anchor.rect.height: target.height + gap
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide    // binnen het scherm houden

    implicitWidth: column.implicitWidth + 2 * padding
    implicitHeight: column.implicitHeight + 2 * padding
    color: "transparent"
    visible: false

    onHoveredChanged: {
        if (hovered) {
            showTimer.restart()
        } else {
            showTimer.stop()
            visible = false
        }
    }

    Timer {
        id: showTimer
        interval: root.showDelay
        onTriggered: root.visible = true
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg      // volledig dekkend: leesbaar boven lichte vensters
        border.color: Theme.selection
        border.width: Theme.borderWidth

        Column {
            id: column
            x: root.padding
            y: root.padding
            spacing: 8
        }
    }
}
