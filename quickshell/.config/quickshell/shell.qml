//@ pragma UseQApplication
// shell.qml: alleen opstarten.
// (UseQApplication is nodig voor QsMenuAnchor, het rechtsklik-menu van de tray.)
// Structuur:
//   Theme / Config / Popups / Icons  gedeelde singletons
//   components/                      herbruikbare UI-bouwstenen
//   services/                        data (cpu, ram, netwerk, weer, capslock)
//   modules/                         bar, launcher, powermenu, notifications
import Quickshell
import qs.modules.bar
import qs.modules.launcher
import qs.modules.powermenu
import qs.modules.notifications

ShellRoot {
    Bar {}
    Launcher {}
    PowerMenu {}
    Notifications {}
}
