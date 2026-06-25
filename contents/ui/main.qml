import QtQml 2.15
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

    FontLoader {
        id: font_anurati
        source: "../fonts/Anurati.otf"
    }
    FontLoader {
        id: font_nasalization
        source: "../fonts/Nasalization.otf"
    }
    FontLoader {
        id: font_weathericons
        source: "../fonts/weathericons-regular-webfont-2.0.11.ttf"
    }

    property string weatherIcon: ""
    property string weatherTemp: ""
    property string weatherCondition: ""
    property string weatherHumidity: ""
    property string weatherFeelsLike: ""
    property string weatherWind: ""
    property string weatherPressure: ""

    function detectLocation() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "http://ip-api.com/json/")
        xhr.timeout = 5000
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    if (data.status === "success") {
                        plasmoid.configuration.weather_latitude = data.lat
                        plasmoid.configuration.weather_longitude = data.lon
                        plasmoid.configuration.weather_city_name = data.city + ", " + data.countryCode
                        plasmoid.configuration.weather_location_set = true
                    }
                }
            }
        }
        xhr.send()
    }

    function getConditionText(code) {
        if (code === 0) return i18n("Clear")
        if (code <= 3) return i18n("Cloudy")
        if (code <= 48) return i18n("Fog")
        if (code <= 55) return i18n("Drizzle")
        if (code <= 65) return i18n("Rain")
        if (code <= 75) return i18n("Snow")
        if (code <= 82) return i18n("Rain Showers")
        if (code >= 95) return i18n("Thunderstorm")
        return ""
    }

    function fetchWeather() {
        var lat = plasmoid.configuration.weather_latitude
        var lon = plasmoid.configuration.weather_longitude
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,precipitation,cloud_cover,wind_speed_10m,wind_gusts_10m,wind_direction_10m,pressure_msl&timezone=auto"

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.timeout = 10000
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    var temp = data.current.temperature_2m
                    var code = data.current.weather_code
                    var hour = new Date().getHours()
                    var isDay = hour >= 6 && hour < 20
                    var celsius = plasmoid.configuration.weather_use_celsius

                    weatherTemp = celsius ? Math.round(temp) + "°" : Math.round(temp * 9/5 + 32) + "°F"
                    weatherIcon = getWeatherIcon(code, isDay)
                    weatherCondition = getConditionText(code)

                    if (data.current.relative_humidity_2m !== undefined)
                        weatherHumidity = i18n("Humidity: ") + data.current.relative_humidity_2m + "%"
                    else
                        weatherHumidity = ""

                    if (data.current.apparent_temperature !== undefined) {
                        var feels = data.current.apparent_temperature
                        weatherFeelsLike = i18n("Feels like ") + (celsius ? Math.round(feels) + "°" : Math.round(feels * 9/5 + 32) + "°F")
                    } else {
                        weatherFeelsLike = ""
                    }

                    if (data.current.wind_speed_10m !== undefined)
                        weatherWind = i18n("Wind: ") + Math.round(data.current.wind_speed_10m) + " km/h"
                    else
                        weatherWind = ""

                    if (data.current.pressure_msl !== undefined)
                        weatherPressure = i18n("Pressure: ") + Math.round(data.current.pressure_msl) + " hPa"
                    else
                        weatherPressure = ""
                } else {
                    weatherTemp = "--"
                    weatherIcon = "\uf07b"
                    weatherCondition = ""
                    weatherHumidity = ""
                    weatherFeelsLike = ""
                    weatherWind = ""
                    weatherPressure = ""
                }
            }
        }
        xhr.send()
    }

    function getWeatherIcon(code, isDay) {
        if (code === 0) return isDay ? "\uf00d" : "\uf02e"
        if (code === 1) return isDay ? "\uf00c" : "\uf081"
        if (code === 2) return isDay ? "\uf002" : "\uf086"
        if (code === 3) return "\uf013"
        if (code >= 45 && code <= 48) return "\uf021"
        if (code >= 51 && code <= 55) return isDay ? "\uf00b" : "\uf02b"
        if (code >= 61 && code <= 65) return isDay ? "\uf008" : "\uf028"
        if (code >= 71 && code <= 75) return isDay ? "\uf00a" : "\uf02a"
        if (code >= 80 && code <= 82) return isDay ? "\uf009" : "\uf029"
        if (code >= 95 && code <= 99) return "\uf01e"
        return "\uf07b"
    }

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.minimumWidth: container.implicitWidth
        Layout.minimumHeight: container.implicitHeight
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        Plasma5Support.DataSource {
            id: dataSource
            engine: "time"
            connectedSources: ["Local"]
            intervalAlignment: Plasma5Support.Types.AlignToMinute
            interval: 60000

            property bool use24HourFormat: plasmoid.configuration.use_24_hour_format

            onUse24HourFormatChanged: dataChanged()

            onDataChanged: {
                var curDate = dataSource.data["Local"]["DateTime"]
                display_day.text = Qt.formatDate(curDate, "dddd").toUpperCase()
                if (use24HourFormat) {
                    display_time_digits.text = Qt.formatTime(curDate, "HH:mm")
                    display_time_ampm.text = ""
                } else {
                    var withAmpm = Qt.formatTime(curDate, "h:mm AP")
                    var idx = withAmpm.indexOf(" AM")
                    if (idx === -1) idx = withAmpm.indexOf(" PM")
                    if (idx !== -1) {
                        display_time_digits.text = withAmpm.substring(0, idx)
                        display_time_ampm.text = withAmpm.substring(idx)
                    } else {
                        display_time_digits.text = withAmpm
                        display_time_ampm.text = ""
                    }
                }
                var dateDay = Qt.formatDate(curDate, "dd")
                var dateMonth = Qt.formatDate(curDate, "MMMM").toUpperCase()
                var dateYear = Qt.formatDate(curDate, "yyyy")
                display_date_day.text = dateDay
                display_date_month.text = dateMonth
                display_date_year.text = dateYear
            }
        }

        Column {
            id: container
            anchors.centerIn: parent
            spacing: 8

            PlasmaComponents.Label {
                id: display_day
                visible: plasmoid.configuration.show_day
                font.pixelSize: plasmoid.configuration.day_font_size
                font.letterSpacing: plasmoid.configuration.day_letter_spacing
                font.family: font_anurati.name
                color: plasmoid.configuration.day_font_color
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 25

                Row {
                    visible: plasmoid.configuration.show_time
                    spacing: 0

                    PlasmaComponents.Label {
                        id: display_time_digits
                        font.pixelSize: plasmoid.configuration.time_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.time_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_time_ampm
                        font.pixelSize: Math.round(plasmoid.configuration.time_font_size * 0.35)
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.time_ampm_color
                        anchors.baseline: display_time_digits.baseline
                        anchors.baselineOffset: -4
                    }
                }

                Row {
                    spacing: 8
                    visible: plasmoid.configuration.show_date_day || plasmoid.configuration.show_date_month || plasmoid.configuration.show_date_year

                    PlasmaComponents.Label {
                        id: display_date_day
                        visible: plasmoid.configuration.show_date_day
                        font.pixelSize: plasmoid.configuration.date_day_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.date_day_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_date_month
                        visible: plasmoid.configuration.show_date_month
                        font.pixelSize: plasmoid.configuration.date_month_font_size
                        font.family: font_anurati.name
                        color: plasmoid.configuration.date_month_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_date_year
                        visible: plasmoid.configuration.show_date_year
                        font.pixelSize: plasmoid.configuration.date_year_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.date_year_font_color
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                visible: plasmoid.configuration.show_weather

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    PlasmaComponents.Label {
                        id: display_weather_icon
                        font.family: font_weathericons.name
                        font.pixelSize: plasmoid.configuration.weather_font_size
                        color: plasmoid.configuration.weather_icon_color
                        text: weatherIcon
                    }

                    PlasmaComponents.Label {
                        id: display_weather_temp
                        font.family: font_nasalization.name
                        font.pixelSize: plasmoid.configuration.weather_font_size
                        color: plasmoid.configuration.weather_temp_color
                        text: weatherTemp
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle {
                    id: weatherSeparator
                    width: 1
                    height: weatherDetailsColumn.implicitHeight
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                Column {
                    id: weatherDetailsColumn
                    spacing: 1

                    PlasmaComponents.Label {
                        id: display_weather_city
                        visible: plasmoid.configuration.weather_show_city && plasmoid.configuration.weather_city_name !== ""
                        text: plasmoid.configuration.weather_city_name
                        font.pixelSize: plasmoid.configuration.weather_city_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_city_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_weather_condition
                        visible: plasmoid.configuration.weather_show_condition && weatherCondition !== ""
                        text: weatherCondition
                        font.pixelSize: plasmoid.configuration.weather_condition_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_condition_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_weather_feelslike
                        visible: plasmoid.configuration.weather_show_feelslike && weatherFeelsLike !== ""
                        text: weatherFeelsLike
                        font.pixelSize: plasmoid.configuration.weather_feelslike_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_feelslike_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_weather_humidity
                        visible: plasmoid.configuration.weather_show_humidity && weatherHumidity !== ""
                        text: weatherHumidity
                        font.pixelSize: plasmoid.configuration.weather_humidity_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_humidity_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_weather_wind
                        visible: plasmoid.configuration.weather_show_wind && weatherWind !== ""
                        text: weatherWind
                        font.pixelSize: plasmoid.configuration.weather_wind_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_wind_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_weather_pressure
                        visible: plasmoid.configuration.weather_show_pressure && weatherPressure !== ""
                        text: weatherPressure
                        font.pixelSize: plasmoid.configuration.weather_pressure_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_pressure_font_color
                    }
                }
            }
        }

        Timer {
            id: weatherTimer
            interval: 1800000
            running: plasmoid.configuration.show_weather
            repeat: true
            onTriggered: fetchWeather()
        }

        Component.onCompleted: {
            if (!plasmoid.configuration.weather_location_set) {
                detectLocation()
            }
            if (plasmoid.configuration.show_weather) {
                fetchWeather()
            }
        }
    }
}
