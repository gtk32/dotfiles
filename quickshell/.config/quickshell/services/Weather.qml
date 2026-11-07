pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Weer van OpenWeatherMap (gratis plan: huidig weer + 5 dagen / 3 uur).
// API-key komt uit de sleutelbos: secret-tool lookup service openweathermap
// (terugval: "apiKey" in weather.json). Locatie staat in weather.json (niet in git).
// Elke 10 min verversen, na een fout na 2 min opnieuw.
Singleton {
    id: root

    // ---------- Instellingen ----------
    property string secretKey: ""    // uit de sleutelbos (voorkeur)
    property string fileKey: ""      // terugval uit weather.json
    readonly property string apiKey: secretKey !== "" ? secretKey : fileKey
    property real lat: NaN
    property real lon: NaN
    property string units: "metric"
    readonly property bool configured: apiKey !== "" && !isNaN(lat) && !isNaN(lon)

    // ---------- Data ----------
    property string label: ""        // in de bar, bv. "Rainy 8°"; leeg = verbergen
    property string place: ""        // plaatsnaam volgens OWM
    property int temp: 0
    property string condition: ""    // bv. "Rainy"
    property string glyph: ""        // Nerd Font-icoon
    property var forecast: []        // [{ day, glyph, condition, min, max }], 5 dagen

    readonly property int refreshInterval: 10 * 60 * 1000
    readonly property int retryInterval: 2 * 60 * 1000

    // ---------- Vertaling OWM -> label/icoon ----------
    function conditionLabel(main) {
        switch (main) {
        case "Thunderstorm": return "Storm"
        case "Drizzle":
        case "Rain": return "Rainy"
        case "Snow": return "Snow"
        case "Clear": return "Clear"
        case "Clouds": return "Clouds"
        default: return "Fog"   // Mist, Haze, Fog, Smoke, Dust, ...
        }
    }

    // OWM-icooncode (bv. "10d") -> Material Design weather-glyph
    function glyphFor(icon) {
        const night = icon.endsWith("n")
        switch (icon.slice(0, 2)) {
        case "01": return Theme.g(night ? 0xf0594 : 0xf0599)   // night / sunny
        case "02": return Theme.g(night ? 0xf0f31 : 0xf0595)   // night-partly-cloudy / partly-cloudy
        case "03":
        case "04": return Theme.g(0xf0590)                      // cloudy
        case "09": return Theme.g(0xf0596)                      // pouring
        case "10": return Theme.g(0xf0597)                      // rainy
        case "11": return Theme.g(0xf0593)                      // lightning
        case "13": return Theme.g(0xf0598)                      // snowy
        case "50": return Theme.g(0xf0591)                      // fog
        default: return Theme.g(0xf0590)
        }
    }

    // ---------- Ophalen ----------
    function _get(endpoint, callback) {
        const url = "https://api.openweathermap.org/data/2.5/" + endpoint
            + "?lat=" + lat + "&lon=" + lon + "&units=" + units + "&appid=" + apiKey
        const xhr = new XMLHttpRequest()
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            let data = null
            if (xhr.status === 200) {
                try { data = JSON.parse(xhr.responseText) } catch (e) {}
            } else {
                console.warn("Weather:", endpoint, "HTTP", xhr.status, xhr.responseText.slice(0, 200))
            }
            callback(data)
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function refresh() {
        if (!configured) {
            label = ""
            forecast = []
            return
        }
        _get("weather", data => {
            const ok = !!(data && data.main && data.weather && data.weather.length)
            if (ok) {
                temp = Math.round(data.main.temp)
                condition = conditionLabel(data.weather[0].main)
                glyph = glyphFor(data.weather[0].icon)
                place = data.name || ""
                label = condition + " " + temp + "°"
            } else {
                label = ""
            }
            timer.interval = ok ? refreshInterval : retryInterval
            timer.restart()
        })
        _get("forecast", data => {
            if (data && data.list) forecast = _daily(data)
        })
    }

    // 3-uurs blokken -> per lokale dag: min/max en het weer rond het middaguur
    function _daily(data) {
        const tz = data.city?.timezone ?? 0
        const days = []
        const byKey = {}
        for (const e of data.list) {
            const local = new Date((e.dt + tz) * 1000)   // UTC-getters = lokale tijd van de plaats
            const key = local.toISOString().slice(0, 10)
            let d = byKey[key]
            if (!d) {
                d = byKey[key] = { date: local, min: Infinity, max: -Infinity, pick: null, pickDist: Infinity }
                days.push(d)
            }
            d.min = Math.min(d.min, e.main.temp_min)
            d.max = Math.max(d.max, e.main.temp_max)
            const dist = Math.abs(local.getUTCHours() - 13)
            if (dist < d.pickDist) { d.pick = e; d.pickDist = dist }
        }
        return days.slice(0, 5).map((d, i) => ({
            day: i === 0 ? "Today" : Qt.locale().dayName(d.date.getUTCDay(), Locale.ShortFormat),
            glyph: glyphFor(d.pick.weather[0].icon),
            condition: conditionLabel(d.pick.weather[0].main),
            min: Math.round(d.min),
            max: Math.round(d.max)
        }))
    }

    // ---------- Instellingen laden (herlaadt bij wijziging) ----------
    FileView {
        path: Quickshell.shellPath("weather.json")
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                const s = JSON.parse(text())
                root.fileKey = s.apiKey || ""
                root.lat = (typeof s.lat === "number") ? s.lat : NaN
                root.lon = (typeof s.lon === "number") ? s.lon : NaN
                root.units = s.units || "metric"
            } catch (e) {
                console.warn("Weather: weather.json is geen geldige JSON:", e)
                root.fileKey = ""
            }
            root.refresh()
        }
        onLoadFailed: { root.fileKey = ""; root.refresh() }
    }

    // ---------- API-key uit de sleutelbos ----------
    // De uitvoer blijft binnen Quickshell en wordt nergens gelogd.
    // Lukt het niet (bv. sleutelbos nog op slot), dan na 1 min opnieuw.
    Process {
        id: secretLookup
        command: ["secret-tool", "lookup", "service", "openweathermap"]
        stdout: StdioCollector {
            onStreamFinished: {
                const key = text.trim()
                if (key !== root.secretKey) {
                    root.secretKey = key
                    root.refresh()
                }
                if (key === "") secretRetry.start()
            }
        }
        Component.onCompleted: running = true
    }
    Timer {
        id: secretRetry
        interval: 60 * 1000
        onTriggered: secretLookup.running = true
    }

    Timer {
        id: timer
        interval: root.refreshInterval; running: root.configured; repeat: true
        onTriggered: root.refresh()
    }
}
