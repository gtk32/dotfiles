import QtQuick
import qs
import qs.components

// Tekstmodule in de bar: vult de volle barhoogte, zodat het klikvlak groot is.
// Zet `clickable: true` om clicked/scrolled te ontvangen.
StyledText {
    id: root

    property bool clickable: false
    property alias acceptedButtons: area.acceptedButtons
    readonly property alias hovered: area.containsMouse

    signal clicked(var mouse)
    signal scrolled(var wheel)

    height: Theme.barHeight
    verticalAlignment: Text.AlignVCenter

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => { if (root.clickable) root.clicked(mouse) }
        onWheel: wheel => root.scrolled(wheel)
    }
}
