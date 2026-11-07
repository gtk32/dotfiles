pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.components
import qs.services

// Hover-venster bij het weer: plaats + nu, daaronder 5 dagen met max/min.
HoverPopup {
    id: root

    readonly property int dayWidth: 52
    readonly property int glyphWidth: 30
    readonly property int condWidth: 70
    readonly property int tempWidth: 40

    // Kop: plaats links, huidig weer rechts
    Item {
        width: days.width
        height: Math.max(header.implicitHeight, now.implicitHeight)

        StyledText {
            id: header
            anchors.left: parent.left
            anchors.right: now.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.place || "Weather"
            font.bold: true
            elide: Text.ElideRight
        }
        Row {
            id: now
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Weather.glyph
                font.pixelSize: Theme.weatherIconSize
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Weather.temp + "°"
                font.bold: true
            }
        }
    }

    Rectangle {
        width: days.width
        height: 1
        color: Theme.selection
    }

    Column {
        id: days
        spacing: 4

        StyledText {
            visible: Weather.forecast.length === 0
            text: "No forecast available"
            color: Theme.dim
            font.pixelSize: Theme.fontSizeSmall
        }

        Repeater {
            model: Weather.forecast

            delegate: Row {
                id: day
                required property var modelData
                height: 28

                StyledText {
                    width: root.dayWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    text: day.modelData.day
                    color: Theme.dim
                }
                StyledText {
                    width: root.glyphWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: day.modelData.glyph
                    font.pixelSize: Theme.weatherIconSize
                }
                StyledText {
                    width: root.condWidth
                    height: parent.height
                    leftPadding: 6
                    verticalAlignment: Text.AlignVCenter
                    text: day.modelData.condition
                }
                StyledText {
                    width: root.tempWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    text: day.modelData.max + "°"
                }
                StyledText {
                    width: root.tempWidth
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    text: day.modelData.min + "°"
                    color: Theme.dim
                }
            }
        }
    }
}
