// Greeter for greetd, runs in cage (xdg-toplevel, no layer-shell).
// Start met: env QT_WAYLAND_DISABLE_WINDOWDECORATION=1 cage -s -- quickshell -p /home/geert/.config/quickshell/greeter
// Theme.qml is a symlink to ../Theme.qml (Moonfly, same as the shell).
// Also works outside greetd (Greetd.available = false): handy for testing the UI.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd

ShellRoot {
    id: root

    // ---------- Settings ----------
    // Patinir, "Landscape with Charon Crossing the Styx" (Prado, c. 1520), public domain
    // Pick a variant with STYX_WALLPAPER=patinir|brueghel|dore-charon (default: patinir)
    readonly property var variants: ({
        "patinir":     { file: "styx-wallpaper.jpg",         card: "bottom", veil: 1.0, keel: 0.70 },
        "brueghel":    { file: "wallpapers/brueghel.jpg",    card: "above",  veil: 0.9, heads: 0.64 },
        "dore-charon": { file: "wallpapers/dore-charon.jpg", card: "center", veil: 0.5, at: 0.66 }
    })
    readonly property var variant: variants[Quickshell.env("STYX_WALLPAPER")] ?? variants["patinir"]
    readonly property url wallpaper: Qt.resolvedUrl(variant.file)
    readonly property string defaultUser: "geert"
    readonly property string stateFile: "/home/geert/.cache/qs-greeter-session"

    // ---------- State ----------
    property var sessions: []          // [{ name, cmd: [..] }]
    property int sessionIndex: 0
    property string message: ""
    property bool messageIsError: false
    property bool busy: false // authenticating or launching
    property bool promptActive: false // greetd asks for an (extra) answer
    property bool promptEcho: false
    property string promptText: ""
    property string pendingPassword: ""
    property bool capsLock: false

    readonly property var session: sessions.length > 0 ? sessions[sessionIndex] : null

    function cycleSession(delta) {
        if (sessions.length === 0) return
        sessionIndex = (sessionIndex + delta + sessions.length) % sessions.length
    }

    function reset(msg, isError) {
        busy = false
        promptActive = false
        pendingPassword = ""
        message = msg
        messageIsError = isError
    }

    function submit(user, secret) {
        if (busy && !promptActive) return
        if (promptActive) {
            // answer to a greetd prompt (e.g. 2FA or password)
            promptActive = false
            message = ""
            Greetd.respond(secret)
            return
        }
        if (user === "" || !session) return
        busy = true
        message = ""
        pendingPassword = secret
        Greetd.createSession(user)
    }

    // ---------- Greetd ----------
    Connections {
        target: Greetd

        function onAuthMessage(msg, isError, responseRequired, echoResponse) {
            if (responseRequired) {
                if (root.pendingPassword !== "" && !echoResponse) {
                    const pw = root.pendingPassword
                    root.pendingPassword = ""
                    Greetd.respond(pw)
                } else {
                    root.promptText = msg
                    root.promptEcho = echoResponse
                    root.promptActive = true
                    root.message = msg
                    root.messageIsError = false
                }
            } else {
                root.message = msg
                root.messageIsError = isError
            }
        }

        function onAuthFailure(msg) {
            root.reset(msg !== "" ? msg : "Authentication failed", true)
        }

        function onReadyToLaunch() {
            if (!root.session) { root.reset("No session found", true); return }
            root.message = "Starting session…"
            root.messageIsError = false
            stateOut.setText(root.session.name + "\n")
            Greetd.launch(root.session.cmd, ["XDG_SESSION_TYPE=wayland"], true)
        }

        function onError(err) {
            root.reset(err, true)
        }
    }

    // ---------- Sessions from /usr/share/wayland-sessions ----------
    Process {
        running: true
        command: ["sh", "-c",
            "for f in /usr/share/wayland-sessions/*.desktop; do " +
            "n=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); " +
            "e=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2-); " +
            "printf '%s\\t%s\\n' \"$n\" \"$e\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                for (const line of text.split("\n")) {
                    const p = line.split("\t")
                    if (p.length < 2 || p[0] === "" || p[1] === "") continue
                    list.push({ name: p[0], cmd: p[1].trim().split(/\s+/) })
                }
                // Hyprland (without uwsm) first as default
                list.sort((a, b) => (a.name === "Hyprland" ? -1 : 0) - (b.name === "Hyprland" ? -1 : 0)
                                    || a.name.localeCompare(b.name))
                root.sessions = list
                lastRead.reload()
            }
        }
    }

    // Remember the last chosen session
    FileView {
        id: lastRead
        path: root.stateFile
        printErrors: false
        onLoaded: {
            const name = text().trim()
            const i = root.sessions.findIndex(s => s.name === name)
            if (i >= 0) root.sessionIndex = i
        }
    }
    FileView {
        id: stateOut
        path: root.stateFile
        printErrors: false
    }

    // ---------- Caps Lock via sysfs ----------
    Process {
        id: capsScan
        command: ["sh", "-c", "cat /sys/class/leds/*::capslock/brightness 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.capsLock = text.split("\n").some(l => Number(l.trim()) > 0)
        }
    }
    Timer {
        interval: 400; running: true; repeat: true; triggeredOnStart: true
        onTriggered: capsScan.running = true
    }

    // ---------- Clock ----------
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // ---------- UI (Adwaita-like, Moonfly colors) ----------
    readonly property string uiFont: "Inter"
    readonly property string serifFont: "Noto Serif" // maybe Cinzel later
    readonly property int radius: 18
    // Styx palette (greeter only): cold, dark, pale gold
    readonly property color ink: "#e8dfc8"
    readonly property color gold: "#c9a96e"
    readonly property color night: "#0a1214"
    readonly property color ember: "#8c3a30"

    FloatingWindow {
        id: win
        visible: true
        color: root.night
        title: "greeter"

        // Wallpaper
        Image {
            id: wall
            anchors.fill: parent
            source: root.wallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize.width: 2560
            sourceSize.height: 1440
        }

        // Dark veil + vignette to keep the clock and card readable
        Rectangle {
            anchors.fill: parent
            opacity: root.variant.veil
            gradient: Gradient {
                GradientStop { position: 0.0;  color: "#b0050a0c" }
                GradientStop { position: 0.35; color: "#50050a0c" }
                GradientStop { position: 0.65; color: "#60050a0c" }
                GradientStop { position: 1.0;  color: "#e0050a0c" }
            }
        }
        Rectangle {
            anchors.fill: parent
            opacity: root.variant.veil
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0;  color: "#80000000" }
                GradientStop { position: 0.25; color: "#00000000" }
                GradientStop { position: 0.75; color: "#00000000" }
                GradientStop { position: 1.0;  color: "#80000000" }
            }
        }

        // Clock and date, white with a soft shadow to stay readable on the painting
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.09
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "S T Y X"
                color: root.gold
                font.family: root.serifFont
                font.pixelSize: 18
                font.weight: Font.Medium
                bottomPadding: 10
            }

            Item {
                width: timeText.width; height: timeText.height
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    x: 0; y: 2; text: timeText.text; color: "#66000000"
                    font: timeText.font
                }
                Text {
                    id: timeText
                    text: Qt.formatTime(clock.date, "HH:mm")
                    color: "#ffffff"
                    font.family: root.serifFont
                    font.pixelSize: 96
                    font.weight: Font.Light
                }
            }
            Item {
                width: dateText.width; height: dateText.height
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    x: 0; y: 1; text: dateText.text; color: "#66000000"
                    font: dateText.font
                }
                Text {
                    id: dateText
                    text: Qt.formatDate(clock.date, "dddd d MMMM")
                    color: root.ink
                    font.family: root.serifFont
                    font.pixelSize: 20
                    font.weight: Font.Normal
                }
            }
        }

        // Card: translucent, dark
        Rectangle {
            id: card
            // Position per variant so the main motif (boat, Charon) stays visible
            x: root.variant.card === "left" ? parent.width * 0.08
               : root.variant.card === "right" ? parent.width - width - parent.width * 0.08
               : (parent.width - width) / 2
            // "bottom": just below the boat keel (keel = relative height in the painting,
            // corrected for PreserveAspectCrop cropping), never off screen
            y: root.variant.card === "bottom"
               ? Math.min((parent.height - wall.paintedHeight) / 2 + wall.paintedHeight * root.variant.keel
                          + parent.height * 0.04,
                          parent.height - height - parent.height * 0.03)
               : root.variant.card === "above"
                 // center, just above the passengers' heads (heads = relative height)
                 ? (parent.height - wall.paintedHeight) / 2 + wall.paintedHeight * root.variant.heads
                   - height - parent.height * 0.03
               : root.variant.at !== undefined
                 // center/side: vertically centered at relative height "at" in the painting
                 ? (parent.height - wall.paintedHeight) / 2 + wall.paintedHeight * root.variant.at - height / 2
               : (parent.height - height) / 2 + parent.height * 0.08
            width: 300
            height: col.implicitHeight + 36
            radius: 8
            color: Qt.rgba(0.04, 0.07, 0.08, 0.78)
            border.width: 1
            border.color: Qt.rgba(0.79, 0.66, 0.43, 0.35)

            Column {
                id: col
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 22
                spacing: 8

                // Username: rectangular field, same size as the password field
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: userField.activeFocus ? root.gold : Qt.rgba(1, 1, 1, 0.12)

                    TextInput {
                        id: userField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        text: root.defaultUser
                        enabled: !root.busy
                        color: root.ink
                        selectionColor: root.gold
                        selectedTextColor: root.night
                        font.family: root.uiFont
                        font.pixelSize: 15
                        clip: true
                        KeyNavigation.tab: pwField
                        onAccepted: pwField.forceActiveFocus()

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: userField.text === "" && !userField.preeditText
                            text: "Username"
                            color: Qt.rgba(1, 1, 1, 0.45)
                            font: userField.font
                        }
                    }
                }

                // Password / answer to a greetd prompt (Enter submits)
                Rectangle {
                    id: pill
                    width: parent.width
                    height: 38
                    radius: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: pwField.activeFocus ? root.gold : Qt.rgba(1, 1, 1, 0.12)

                    TextInput {
                        id: pwField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true
                        enabled: !root.busy || root.promptActive
                        color: root.ink
                        selectionColor: root.gold
                        selectedTextColor: root.night
                        font.family: root.uiFont
                        font.pixelSize: 15
                        echoMode: (root.promptActive && root.promptEcho) ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "●"
                        clip: true
                        KeyNavigation.tab: userField
                        onAccepted: {
                            root.submit(userField.text, text)
                            text = ""
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: pwField.text === "" && !pwField.preeditText
                            text: root.promptActive ? root.promptText.replace(/:\s*$/, "") : "Password"
                            color: Qt.rgba(1, 1, 1, 0.45)
                            font: pwField.font
                        }
                    }
                }

                // Status
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                    wrapMode: Text.WordWrap
                    text: root.message !== "" ? root.message
                          : (root.capsLock ? "Caps Lock is on" : "")
                    color: root.messageIsError ? root.ember
                           : (root.message === "" && root.capsLock ? root.gold : Qt.rgba(1, 1, 1, 0.75))
                    font.family: root.uiFont
                    font.pixelSize: 14
                }

                // Session picker
                Rectangle {
                    width: parent.width
                    height: 30
                    radius: 4
                    color: sessionArea.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.07)

                    Row {
                        id: sessionRow
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.session ? root.session.name : "—"
                            color: "#ffffff"
                            font.family: root.uiFont
                            font.pixelSize: 14
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "⌄"
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.family: root.uiFont
                            font.pixelSize: 14
                        }
                    }
                    MouseArea {
                        id: sessionArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.cycleSession(1)
                    }
                }
            }
        }

        // Muted power buttons, bottom right
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 24
            spacing: 10

            Repeater {
                model: [
                    { label: "Reboot",   cmd: ["systemctl", "reboot"] },
                    { label: "Poweroff", cmd: ["systemctl", "poweroff"] }
                ]
                delegate: Rectangle {
                    id: pbtn
                    required property var modelData
                    width: 88; height: 30; radius: 4
                    color: pm.containsMouse ? Qt.lighter(root.ember, 1.15) : root.ember
                    Text {
                        anchors.centerIn: parent
                        text: pbtn.modelData.label
                        color: "#ffffff"
                        font.family: root.uiFont
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        id: pm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Quickshell.execDetached(pbtn.modelData.cmd)
                    }
                }
            }
        }

        // Shortcuts: F2/F3 or Ctrl+Left/Right switch session, Esc cancels
        Item {
            anchors.fill: parent
            Shortcut { sequence: "F2"; onActivated: root.cycleSession(-1) }
            Shortcut { sequence: "F3"; onActivated: root.cycleSession(1) }
            Shortcut { sequence: "Ctrl+Left"; onActivated: root.cycleSession(-1) }
            Shortcut { sequence: "Ctrl+Right"; onActivated: root.cycleSession(1) }
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    if (Greetd.available) Greetd.cancelSession()
                    root.reset("", false)
                    pwField.text = ""
                    pwField.forceActiveFocus()
                }
            }
        }

        Text {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 14
            visible: !Greetd.available
            text: "greetd unavailable (test mode)"
            color: "#ffffff"
            opacity: 0.7
            font.family: root.uiFont
            font.pixelSize: 12
        }
    }
}
