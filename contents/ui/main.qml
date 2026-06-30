import QtQml
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

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
        source: "../fonts/weathericons-regular-webfont.ttf"
    }

    property string weatherIcon: ""
    property string weatherTemp: ""
    property string weatherCondition: ""
    property string weatherHumidity: ""
    property string weatherFeelsLike: ""
    property string weatherWind: ""
    property string weatherPressure: ""

    property string resolvedTempUnit: "celsius"
    property string resolvedWindUnit: "kmh"
    property string resolvedPressureUnit: "hpa"

    function detectLocation() {
        var xhr = new XMLHttpRequest()
        // Usamos geojs.io que es HTTPS, gratuita y no bloquea widgets de QML
        xhr.open("GET", "https://get.geojs.io/v1/ip/geo.json")
        xhr.timeout = 5000
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText)

                        // GeoJS devuelve los datos como texto, usamos parseFloat para convertirlos a números
                        if (data.latitude && data.longitude) {
                            plasmoid.configuration.weather_latitude = parseFloat(data.latitude)
                            plasmoid.configuration.weather_longitude = parseFloat(data.longitude)
                            plasmoid.configuration.weather_city_name = data.city + ", " + data.country_code
                            plasmoid.configuration.weather_location_set = true
                        }
                    } catch (e) {
                        console.error("Error al procesar el JSON: " + e)
                    }
                } else {
                    console.error("Fallo en la petición HTTP: Código " + xhr.status)
                }
            }
        }
        xhr.send()
    }

    function getLocale() {
        var ov = plasmoid.configuration.date_locale_override
        return ov ? Qt.locale(ov) : Qt.locale()
    }

    function langCode() {
        return getLocale().name.split("_")[0]
    }

    function trCond(code) {
        var lang = langCode()
        var c = {
            0: { en: "Clear", es: "Despejado", fr: "Dégagé", de: "Klar", it: "Sereno", pt: "Limpo", nl: "Helder", ru: "Ясно", pl: "Bezchmurnie" },
            1: { en: "Cloudy", es: "Nublado", fr: "Nuageux", de: "Bewölkt", it: "Nuvoloso", pt: "Nublado", nl: "Bewolkt", ru: "Облачно", pl: "Pochmurnie" },
            2: { en: "Cloudy", es: "Nublado", fr: "Nuageux", de: "Bewölkt", it: "Nuvoloso", pt: "Nublado", nl: "Bewolkt", ru: "Облачно", pl: "Pochmurnie" },
            3: { en: "Overcast", es: "Cubierto", fr: "Couvert", de: "Bedeckt", it: "Coperto", pt: "Encoberto", nl: "Betrokken", ru: "Пасмурно", pl: "Pochmurno" },
            45: { en: "Fog", es: "Niebla", fr: "Brouillard", de: "Nebel", it: "Nebbia", pt: "Nevoeiro", nl: "Mist", ru: "Туман", pl: "Mgła" },
            51: { en: "Drizzle", es: "Llovizna", fr: "Bruine", de: "Niesel", it: "Pioggerella", pt: "Chuvisco", nl: "Motregen", ru: "Морось", pl: "Mżawka" },
            61: { en: "Rain", es: "Lluvia", fr: "Pluie", de: "Regen", it: "Pioggia", pt: "Chuva", nl: "Regen", ru: "Дождь", pl: "Deszcz" },
            71: { en: "Snow", es: "Nieve", fr: "Neige", de: "Schnee", it: "Neve", pt: "Neve", nl: "Sneeuw", ru: "Снег", pl: "Śnieg" },
            80: { en: "Rain Showers", es: "Chubascos", fr: "Averses", de: "Regenschauer", it: "Rovesci", pt: "Aguaceiros", nl: "Regenbuien", ru: "Ливни", pl: "Ulewy" },
            95: { en: "Thunderstorm", es: "Tormenta", fr: "Orage", de: "Gewitter", it: "Temporale", pt: "Tempestade", nl: "Onweer", ru: "Гроза", pl: "Burza" }
        }
        var row = c[0]
        if (code <= 3) row = code === 0 ? c[0] : code === 1 ? c[1] : code === 2 ? c[2] : c[3]
        else if (code <= 48) row = c[45]
        else if (code <= 55) row = c[51]
        else if (code <= 65) row = c[61]
        else if (code <= 75) row = c[71]
        else if (code <= 82) row = c[80]
        else if (code >= 95) row = c[95]
        else return ""
        return row[lang] || row["en"]
    }

    function trLabel(key) {
        var lang = langCode()
        var labels = {
            humidity: { en: "Humidity: ", es: "Humedad: ", fr: "Humidité: ", de: "Luftfeuchtigkeit: ", it: "Umidità: ", pt: "Umidade: ",
                        nl: "Luchtvochtigheid: ", ru: "Влажность: ", pl: "Wilgotność: ", ja: "湿度: ", ko: "습도: ", zh: "湿度: " },
            feelslike: { en: "Feels like ", es: "Sensación térmica: ", fr: "Ressenti: ", de: "Gefühlt: ", it: "Percepita: ", pt: "Sensação: ",
                         nl: "Gevoelstemperatuur: ", ru: "Ощущается как: ", pl: "Odczuwalna: ", ja: "体感温度: ", ko: "체감온도: ", zh: "体感: " },
            wind: { en: "Wind: ", es: "Viento: ", fr: "Vent: ", de: "Wind: ", it: "Vento: ", pt: "Vento: ",
                    nl: "Wind: ", ru: "Ветер: ", pl: "Wiatr: ", ja: "風: ", ko: "바람: ", zh: "风: " },
            pressure: { en: "Pressure: ", es: "Presión: ", fr: "Pression: ", de: "Druck: ", it: "Pressione: ", pt: "Pressão: ",
                        nl: "Druk: ", ru: "Давление: ", pl: "Ciśnienie: ", ja: "気圧: ", ko: "기압: ", zh: "气压: " }
        }
        var row = labels[key]
        return row && row[lang] !== undefined ? row[lang] : labels[key]["en"]
    }

    function resolveUnits() {
        var temp = plasmoid.configuration.weather_temperature_unit
        var wind = plasmoid.configuration.weather_wind_unit
        var pressure = plasmoid.configuration.weather_pressure_unit

        resolvedTempUnit = temp && temp !== "" ? temp : "celsius"
        resolvedWindUnit = wind && wind !== "" ? wind : "kmh"
        resolvedPressureUnit = pressure && pressure !== "" ? pressure : "hpa"
    }

    function tempLabel() {
        if (resolvedTempUnit === "fahrenheit") return "&nbsp;<font face='" + font_weathericons.name + "'>\uf045</font>"
            if (resolvedTempUnit === "kelvin") return "&nbsp;K"
                return "&nbsp;<font face='" + font_weathericons.name + "'>\uf03c</font>"
    }

    function windLabel() {
        if (resolvedWindUnit === "mph") return " mph"
        if (resolvedWindUnit === "ms") return " m/s"
        if (resolvedWindUnit === "knots") return " kt"
        return " km/h"
    }

    function fetchWeather() {
        resolveUnits()
        var lat = plasmoid.configuration.weather_latitude
        var lon = plasmoid.configuration.weather_longitude
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,precipitation,cloud_cover,wind_speed_10m,wind_gusts_10m,wind_direction_10m,pressure_msl&timezone=auto&temperature_unit=" + resolvedTempUnit + "&wind_speed_unit=" + resolvedWindUnit

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.timeout = 10000
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    var code = data.current.weather_code
                    var hour = new Date().getHours()
                    var isDay = hour >= 6 && hour < 20

                    weatherTemp = Math.round(data.current.temperature_2m) + tempLabel()
                    weatherIcon = getWeatherIcon(code, isDay)
                    weatherCondition = trCond(code) + "&nbsp;&nbsp;<font face='" + font_weathericons.name + "'>" + weatherIcon + "</font>"

                    if (data.current.relative_humidity_2m !== undefined) {
                        // Reemplazamos el "%" por el ícono de humedad usando HTML
                        weatherHumidity = trLabel("humidity") + data.current.relative_humidity_2m + "&nbsp;<font face='" + font_weathericons.name + "'>\uf07a</font>"
                    } else {
                        weatherHumidity = ""
                    }

                    if (data.current.apparent_temperature !== undefined)
                        weatherFeelsLike = trLabel("feelslike") + Math.round(data.current.apparent_temperature) + tempLabel()
                    else
                        weatherFeelsLike = ""

                    if (data.current.wind_speed_10m !== undefined)
                        weatherWind = trLabel("wind") + Math.round(data.current.wind_speed_10m) + windLabel()
                    else
                        weatherWind = ""

                    if (data.current.pressure_msl !== undefined) {
                        var pval = data.current.pressure_msl
                        var plabel = " hPa"
                        if (resolvedPressureUnit === "inhg") {
                            pval = pval * 0.02953
                            plabel = " inHg"
                        } else if (resolvedPressureUnit === "mmhg") {
                            pval = pval * 0.75006
                            plabel = " mmHg"
                        }
                        weatherPressure = trLabel("pressure") + Math.round(pval) + plabel
                    } else
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

        function updateClock() {
            var curDate = new Date()
            var locale = root.getLocale()
            var jsDay = curDate.getDay()
            var qtDay = jsDay === 0 ? 7 : jsDay
            display_day.text = locale.standaloneDayName(qtDay).toUpperCase()

            if (plasmoid.configuration.use_24_hour_format) {
                display_time_digits.text = Qt.formatTime(curDate, "HH:mm")
                display_time_ampm.text = ""
            } else {
                var hours = curDate.getHours()
                var minutes = curDate.getMinutes()
                var minStr = minutes < 10 ? "0" + minutes : String(minutes)
                var h12 = hours % 12
                if (h12 === 0) h12 = 12
                display_time_digits.text = h12 + ":" + minStr
                display_time_ampm.text = hours < 12 ? locale.amText : locale.pmText
            }

            var dateDay = Qt.formatDate(curDate, "dd")
            var dateMonth = locale.standaloneMonthName(curDate.getMonth()).toUpperCase()
            var dateYear = Qt.formatDate(curDate, "yyyy")
            display_date_day.text = dateDay
            display_date_month.text = dateMonth
            display_date_year.text = dateYear
        }

        Connections {
            target: plasmoid.configuration

            function onWeather_temperature_unitChanged() { fetchWeather() }
            function onWeather_wind_unitChanged() { fetchWeather() }
            function onWeather_pressure_unitChanged() { fetchWeather() }
            function onDate_locale_overrideChanged() { updateClock(); fetchWeather() }
            function onUse_24_hour_formatChanged() { updateClock() }
        }

        Timer {
            id: clockTimer
            interval: 60000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: updateClock()
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

                Row { // <-- Cambiamos Column por Row
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10 // Espacio entre el termómetro y los números (puedes ajustarlo)

                    PlasmaComponents.Label {
                        id: display_weather_icon
                        font.family: font_weathericons.name
                        font.pixelSize: plasmoid.configuration.weather_font_size
                        color: plasmoid.configuration.weather_icon_color
                        textFormat: Text.RichText
                        text: "\uf055" // El termómetro
                        anchors.verticalCenter: parent.verticalCenter // Para que quede a la misma altura que los números
                    }

                    PlasmaComponents.Label {
                        id: display_weather_temp
                        font.family: font_nasalization.name
                        font.pixelSize: plasmoid.configuration.weather_font_size
                        color: plasmoid.configuration.weather_temp_color
                        textFormat: Text.RichText
                        text: weatherTemp // Aquí está el número y el ícono de ºC / ºF
                        anchors.verticalCenter: parent.verticalCenter // Para que quede a la misma altura que el termómetro
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
                        textFormat: Text.RichText
                    }

                    PlasmaComponents.Label {
                        id: display_weather_feelslike
                        visible: plasmoid.configuration.weather_show_feelslike && weatherFeelsLike !== ""
                        text: weatherFeelsLike
                        textFormat: Text.RichText
                        font.pixelSize: plasmoid.configuration.weather_feelslike_font_size
                        font.family: font_nasalization.name
                        color: plasmoid.configuration.weather_feelslike_font_color
                    }

                    PlasmaComponents.Label {
                        id: display_weather_humidity
                        visible: plasmoid.configuration.weather_show_humidity && weatherHumidity !== ""
                        textFormat: Text.RichText
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
            interval: 120000
            running: plasmoid.configuration.show_weather
            repeat: true
            onTriggered: fetchWeather()
        }

        Component.onCompleted: {
            if (!plasmoid.configuration.weather_units_initialized) {
                var locale = Qt.locale()
                if (locale.name === "en_US") {
                    plasmoid.configuration.weather_temperature_unit = "fahrenheit"
                    plasmoid.configuration.weather_wind_unit = "mph"
                    plasmoid.configuration.weather_pressure_unit = "inhg"
                } else {
                    plasmoid.configuration.weather_temperature_unit = "celsius"
                    plasmoid.configuration.weather_wind_unit = "kmh"
                    plasmoid.configuration.weather_pressure_unit = "hpa"
                }
                plasmoid.configuration.weather_units_initialized = true
            }
            if (!plasmoid.configuration.weather_location_set) {
                detectLocation()
            }
            if (plasmoid.configuration.show_weather) {
                fetchWeather()
            }
        }
    }
}
