pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs
import qs.components

// Eén melding. Linksklik = standaardactie van de app (bv. venster openen) en sluiten,
// rechtsklik = alleen sluiten, muis erboven = timer pauzeert.
Rectangle {
    id: card

    required property Notification modelData

    readonly property string level: levelOf(modelData)
    readonly property var look: looks[level]
    readonly property string icon: Icons.resolve(modelData.appIcon)

    // Opmaak per niveau
    readonly property var looks: ({
        info:    { border: Theme.highlight, bg: Theme.bg,      tag: "",        glyph: 0xf02fc },
        warning: { border: Theme.yellow,    bg: Theme.warnBg,  tag: "WARNING", glyph: 0xf0026 },
        error:   { border: Theme.warn,      bg: Theme.errorBg, tag: "ERROR",   glyph: 0xf0028 }
    })

    // Critical urgency of een foutwoord in de titel = error,
    // waarschuwingswoord in de titel = warning, de rest = info
    function levelOf(n) {
        if (n.urgency === NotificationUrgency.Critical) return "error"
        const t = (n.summary || "").toLowerCase()
        if (/(error|failed|failure|fatal|crash|mislukt|fout)/.test(t)) return "error"
        if (/(warning|warn|waarschuwing|attention|low battery)/.test(t)) return "warning"
        return "info"
    }

    // Time-out in seconden. Een melding blijft nooit eeuwig staan.
    function timeoutFor(n, lvl) {
        if (n.urgency === NotificationUrgency.Low) return 4
        let t = n.expireTimeout
        if (t > 1000) t = t / 1000                  // voor het geval het in ms binnenkomt
        if (t > 0) return Math.min(20, Math.max(lvl === "info" ? 3 : 8, t))
        return lvl === "error" ? 20 : (lvl === "warning" ? 10 : 6)
    }

    height: Math.max(60, textCol.implicitHeight + 24)
    color: Qt.alpha(look.bg, Theme.notificationOpacity)
    border.color: look.border
    border.width: Theme.borderWidth

    // Herstart de timer als een app de melding bijwerkt (bv. Spotify, Teams)
    Connections {
        target: card.modelData
        function onSummaryChanged() { life.restart() }
        function onBodyChanged() { life.restart() }
    }

    Timer {
        id: life
        interval: card.timeoutFor(card.modelData, card.level) * 1000
        running: !area.containsMouse
        onTriggered: card.modelData.expire()
    }

    Item {
        anchors.fill: parent
        anchors.margins: 12

        // Afbeelding, app-icoon of niveau-glyph
        Item {
            id: iconBox
            width: 36
            height: 36

            Image {
                anchors.fill: parent
                visible: !!card.modelData.image
                source: card.modelData.image ?? ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }
            IconImage {
                anchors.fill: parent
                visible: !card.modelData.image && card.icon !== ""
                source: card.icon
            }
            StyledText {
                anchors.centerIn: parent
                visible: !card.modelData.image && card.icon === ""
                text: Theme.g(card.look.glyph)
                color: card.look.border
                font.pixelSize: Theme.iconSizeLarge
            }
        }

        Column {
            id: textCol
            anchors.left: iconBox.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            spacing: 3

            Row {
                spacing: 8
                StyledText {
                    visible: card.look.tag !== ""
                    text: Theme.g(card.look.glyph) + " " + card.look.tag
                    color: card.look.border
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                }
                StyledText {
                    text: card.modelData.appName
                    color: Theme.dim
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            StyledText {
                width: parent.width
                text: card.modelData.summary
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            StyledText {
                width: parent.width
                visible: text !== ""
                text: card.modelData.body
                font.pixelSize: Theme.fontSizeBody
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            const n = card.modelData
            if (mouse.button === Qt.LeftButton) {
                const def = n.actions.find(a => a.identifier === "default")
                if (def) {
                    // invoke() sluit een niet-residente melding zelf al af;
                    // daarna is `n` vernietigd en mag dismiss() niet meer.
                    const resident = n.resident
                    def.invoke()
                    if (!resident) return
                }
            }
            n.dismiss()
        }
    }
}
