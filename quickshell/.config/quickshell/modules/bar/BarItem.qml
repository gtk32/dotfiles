import QtQuick
import qs
import qs.components

// Bar-module met een los (groter) icoon en optioneel een label ernaast.
// Nerd Font-glyphs uit Material Design renderen klein op tekstgrootte,
// daarom krijgt het icoon een eigen grootte (Theme.barIconSize).
Item {
    id: root

    property string icon: ""
    property string text: ""
    property color color: Theme.fg
    property color iconColor: color
    property int iconSize: Theme.barIconSize
    property bool clickable: false

    readonly property alias hovered: area.containsMouse

    signal clicked(var mouse)
    signal scrolled(var wheel)

    implicitWidth: row.implicitWidth
    height: Theme.barHeight

    Row {
        id: row
        height: parent.height
        spacing: 6

        StyledText {
            visible: root.icon !== ""
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            text: root.icon
            color: root.iconColor
            font.pixelSize: root.iconSize
        }
        StyledText {
            visible: root.text !== ""
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            text: root.text
            color: root.color
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => { if (root.clickable) root.clicked(mouse) }
        onWheel: wheel => root.scrolled(wheel)
    }
}
