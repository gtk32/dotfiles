pragma Singleton

import QtQuick
import Quickshell

// Gedeelde klok (minuutprecisie) en datumhulpjes
Singleton {
    id: root

    readonly property date date: clock.date

    // ISO 8601-weeknummer (week begint op maandag, week 1 bevat de eerste donderdag)
    function isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
        const day = t.getUTCDay() || 7
        t.setUTCDate(t.getUTCDate() + 4 - day)
        const y0 = new Date(Date.UTC(t.getUTCFullYear(), 0, 1))
        return Math.ceil(((t - y0) / 86400000 + 1) / 7)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
