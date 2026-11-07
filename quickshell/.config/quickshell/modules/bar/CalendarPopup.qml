pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.components
import qs.services

// Hover-venster bij de klok: maandoverzicht, maandag eerst, met ISO-weeknummers.
// Altijd 6 weken, zodat het venster niet van grootte verspringt.
HoverPopup {
    id: root

    readonly property date today: Time.date
    readonly property int year: today.getFullYear()
    readonly property int month: today.getMonth()

    // Maandag op of vóór de 1e van de maand
    readonly property date gridStart: {
        const first = new Date(year, month, 1)
        return new Date(year, month, 1 - (first.getDay() + 6) % 7)
    }

    readonly property int cellWidth: 30
    readonly property int cellHeight: 24
    readonly property var weekdays: [1, 2, 3, 4, 5, 6, 0]   // ma..zo (Qt: 0 = zondag)

    function cellDate(row, col) {
        return new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + row * 7 + col)
    }

    // Maand en jaar
    StyledText {
        width: days.width
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDate(root.today, "MMMM yyyy")
        font.bold: true
    }

    Column {
        id: days

        // Dagnamen
        Row {
            Item { width: root.cellWidth; height: root.cellHeight }   // boven de weeknummers
            Repeater {
                model: root.weekdays
                delegate: StyledText {
                    required property int modelData
                    width: root.cellWidth
                    height: root.cellHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: Qt.locale().dayName(modelData, Locale.ShortFormat).slice(0, 2)
                    color: Theme.dim
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.selection
        }

        // Zes weken: weeknummer + 7 dagen
        Repeater {
            model: 6

            delegate: Row {
                id: week
                required property int index

                StyledText {
                    width: root.cellWidth
                    height: root.cellHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: Time.isoWeek(root.cellDate(week.index, 0))
                    color: Theme.dim
                    font.pixelSize: Theme.fontSizeSmall
                }

                Repeater {
                    model: 7

                    delegate: Item {
                        id: cell
                        required property int index
                        readonly property date d: root.cellDate(week.index, index)
                        readonly property bool inMonth: d.getMonth() === root.month
                        readonly property bool isToday: d.toDateString() === root.today.toDateString()

                        width: root.cellWidth
                        height: root.cellHeight

                        Rectangle {
                            anchors.centerIn: parent
                            width: root.cellHeight
                            height: root.cellHeight
                            radius: height / 2
                            visible: cell.isToday
                            color: Theme.highlight
                        }
                        StyledText {
                            anchors.centerIn: parent
                            text: cell.d.getDate()
                            color: cell.isToday ? Theme.bg : (cell.inMonth ? Theme.fg : Theme.dim)
                            font.pixelSize: Theme.fontSizeBody
                            font.bold: cell.isToday
                        }
                    }
                }
            }
        }
    }
}
