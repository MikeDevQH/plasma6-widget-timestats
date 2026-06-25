import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls

Kirigami.ScrollablePage {
    id: appearancePage

    property alias cfg_show_day: showDay.checked
    property alias cfg_day_font_size: dayFontSize.value
    property alias cfg_day_font_color: dayFontColor.color
    property alias cfg_day_letter_spacing: dayLetterSpacing.value
    property alias cfg_show_time: showTime.checked
    property alias cfg_time_font_size: timeFontSize.value
    property alias cfg_time_font_color: timeFontColor.color
    property alias cfg_time_ampm_color: timeAmpmColor.color
    property alias cfg_use_24_hour_format: use24HourFormat.checked
    property alias cfg_show_date_day: showDateDay.checked
    property alias cfg_date_day_font_size: dateDayFontSize.value
    property alias cfg_date_day_font_color: dateDayFontColor.color
    property alias cfg_show_date_month: showDateMonth.checked
    property alias cfg_date_month_font_size: dateMonthFontSize.value
    property alias cfg_date_month_font_color: dateMonthFontColor.color
    property alias cfg_show_date_year: showDateYear.checked
    property alias cfg_date_year_font_size: dateYearFontSize.value
    property alias cfg_date_year_font_color: dateYearFontColor.color
    property alias cfg_show_weather: showWeather.checked
    property alias cfg_weather_temp_color: weatherTempColor.color
    property alias cfg_weather_icon_color: weatherIconColor.color
    property alias cfg_weather_font_size: weatherFontSize.value
    property alias cfg_weather_use_celsius: useCelsius.checked
    property alias cfg_weather_show_city: weatherShowCity.checked
    property alias cfg_weather_city_font_size: weatherCityFontSize.value
    property alias cfg_weather_city_font_color: weatherCityFontColor.color
    property alias cfg_weather_show_condition: weatherShowCondition.checked
    property alias cfg_weather_condition_font_size: weatherConditionFontSize.value
    property alias cfg_weather_condition_font_color: weatherConditionFontColor.color
    property alias cfg_weather_show_feelslike: weatherShowFeelslike.checked
    property alias cfg_weather_feelslike_font_size: weatherFeelslikeFontSize.value
    property alias cfg_weather_feelslike_font_color: weatherFeelslikeFontColor.color
    property alias cfg_weather_show_humidity: weatherShowHumidity.checked
    property alias cfg_weather_humidity_font_size: weatherHumidityFontSize.value
    property alias cfg_weather_humidity_font_color: weatherHumidityFontColor.color
    property alias cfg_weather_show_wind: weatherShowWind.checked
    property alias cfg_weather_wind_font_size: weatherWindFontSize.value
    property alias cfg_weather_wind_font_color: weatherWindFontColor.color
    property alias cfg_weather_show_pressure: weatherShowPressure.checked
    property alias cfg_weather_pressure_font_size: weatherPressureFontSize.value
    property alias cfg_weather_pressure_font_color: weatherPressureFontColor.color

    ListModel { id: searchModel }

    function searchCity(name) {
        searchModel.clear()
        if (name.length < 2) return
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(name) + "&count=10&language=en&format=json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    var results = data.results || []
                    for (var i = 0; i < results.length; i++)
                        searchModel.append(results[i])
                }
            }
        }
        xhr.send()
    }

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

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            text: i18n("Day of Week")
            level: 2
        }

        RowLayout {
            CheckBox { id: showDay }
            Label { text: i18n("Show Day") }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Spacing") }
            SpinBox { id: dayLetterSpacing; from: 0; to: 999 }
        }
        RowLayout {
            Label { text: i18n("Size") }
            SpinBox { id: dayFontSize; from: 1; to: 999 }
            Item { Layout.fillWidth: true }
            ColorDial { id: dayFontColor; color: cfg_day_font_color; label: i18n("Color") }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.Heading {
            text: i18n("Time")
            level: 2
        }

        RowLayout {
            CheckBox { id: showTime }
            Label { text: i18n("Show Time") }
            Item { Layout.fillWidth: true }
            CheckBox { id: use24HourFormat }
            Label { text: i18n("24-hour format") }
        }
        RowLayout {
            Label { text: i18n("Size") }
            SpinBox { id: timeFontSize; from: 1; to: 999 }
            Item { Layout.fillWidth: true }
            ColorDial { id: timeFontColor; color: cfg_time_font_color; label: i18n("Digits") }
            Item { width: Kirigami.Units.gridUnit }
            ColorDial { id: timeAmpmColor; color: cfg_time_ampm_color; label: i18n("AM/PM") }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.Heading {
            text: i18n("Date")
            level: 2
        }

        RowLayout {
            CheckBox { id: showDateDay }
            Label { text: i18n("Day") }
            Item { width: Kirigami.Units.gridUnit }
            CheckBox { id: showDateMonth }
            Label { text: i18n("Month") }
            Item { width: Kirigami.Units.gridUnit }
            CheckBox { id: showDateYear }
            Label { text: i18n("Year") }
        }
        RowLayout {
            Label { text: i18n("Day Size") }
            SpinBox { id: dateDayFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            Label { text: i18n("Month Size") }
            SpinBox { id: dateMonthFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            Label { text: i18n("Year Size") }
            SpinBox { id: dateYearFontSize; from: 1; to: 999 }
        }
        RowLayout {
            ColorDial { id: dateDayFontColor; color: cfg_date_day_font_color; label: i18n("Day") }
            Item { width: Kirigami.Units.gridUnit }
            ColorDial { id: dateMonthFontColor; color: cfg_date_month_font_color; label: i18n("Month") }
            Item { width: Kirigami.Units.gridUnit }
            ColorDial { id: dateYearFontColor; color: cfg_date_year_font_color; label: i18n("Year") }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.Heading {
            text: i18n("Weather")
            level: 2
        }

        RowLayout {
            CheckBox { id: showWeather }
            Label { text: i18n("Show Weather") }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Use Celsius") }
            CheckBox { id: useCelsius }
            Item { width: Kirigami.Units.gridUnit }
            Label { text: i18n("Font Size") }
            SpinBox { id: weatherFontSize; from: 1; to: 999 }
        }

        Kirigami.Heading {
            text: i18n("Location")
            level: 3
        }

        RowLayout {
            TextField {
                id: citySearch
                placeholderText: i18n("Search city...")
                implicitWidth: Kirigami.Units.gridUnit * 12
                onAccepted: searchCity(text)
            }
            Button {
                text: i18n("Search")
                icon.name: "edit-find"
                onClicked: searchCity(citySearch.text)
            }
        }

        Repeater {
            model: searchModel
            delegate: RowLayout {
                visible: searchModel.count > 0
                Label { text: model.name + ", " + (model.country || model.country_code) }
                Button {
                    text: i18n("Select")
                    icon.name: "emblem-default"
                    onClicked: {
                        plasmoid.configuration.weather_latitude = model.latitude
                        plasmoid.configuration.weather_longitude = model.longitude
                        plasmoid.configuration.weather_city_name = model.name + ", " + (model.country || model.country_code)
                        plasmoid.configuration.weather_location_set = true
                        searchModel.clear()
                    }
                }
            }
        }

        Label {
            text: plasmoid.configuration.weather_city_name
                ? i18n("Selected: ") + plasmoid.configuration.weather_city_name
                : i18n("No city selected")
        }

        RowLayout {
            Button {
                text: i18n("Detect Automatically")
                icon.name: "find-location"
                onClicked: detectLocation()
            }
            Item { Layout.fillWidth: true }
            ColorDial { id: weatherTempColor; color: cfg_weather_temp_color; label: i18n("Temp Color") }
            Item { width: Kirigami.Units.gridUnit }
            ColorDial { id: weatherIconColor; color: cfg_weather_icon_color; label: i18n("Icon Color") }
        }

        Kirigami.Heading {
            text: i18n("City")
            level: 3
        }

        RowLayout {
            CheckBox { id: weatherShowCity }
            Label { text: i18n("Show City") }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Size") }
            SpinBox { id: weatherCityFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            KQControls.ColorButton {
                id: weatherCityFontColor
                showAlphaChannel: false
                onAccepted: cfg_weather_city_font_color = color
            }
        }

        Kirigami.Heading {
            text: i18n("Details")
            level: 3
        }

        RowLayout {
            CheckBox { id: weatherShowCondition }
            Label { text: i18n("Condition"); Layout.minimumWidth: Kirigami.Units.gridUnit * 5 }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Size") }
            SpinBox { id: weatherConditionFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            KQControls.ColorButton {
                id: weatherConditionFontColor
                showAlphaChannel: false
                onAccepted: cfg_weather_condition_font_color = color
            }
        }
        RowLayout {
            CheckBox { id: weatherShowFeelslike }
            Label { text: i18n("Feels Like"); Layout.minimumWidth: Kirigami.Units.gridUnit * 5 }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Size") }
            SpinBox { id: weatherFeelslikeFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            KQControls.ColorButton {
                id: weatherFeelslikeFontColor
                showAlphaChannel: false
                onAccepted: cfg_weather_feelslike_font_color = color
            }
        }
        RowLayout {
            CheckBox { id: weatherShowHumidity }
            Label { text: i18n("Humidity"); Layout.minimumWidth: Kirigami.Units.gridUnit * 5 }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Size") }
            SpinBox { id: weatherHumidityFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            KQControls.ColorButton {
                id: weatherHumidityFontColor
                showAlphaChannel: false
                onAccepted: cfg_weather_humidity_font_color = color
            }
        }
        RowLayout {
            CheckBox { id: weatherShowWind }
            Label { text: i18n("Wind"); Layout.minimumWidth: Kirigami.Units.gridUnit * 5 }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Size") }
            SpinBox { id: weatherWindFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            KQControls.ColorButton {
                id: weatherWindFontColor
                showAlphaChannel: false
                onAccepted: cfg_weather_wind_font_color = color
            }
        }
        RowLayout {
            CheckBox { id: weatherShowPressure }
            Label { text: i18n("Pressure"); Layout.minimumWidth: Kirigami.Units.gridUnit * 5 }
            Item { Layout.fillWidth: true }
            Label { text: i18n("Size") }
            SpinBox { id: weatherPressureFontSize; from: 1; to: 999 }
            Item { width: Kirigami.Units.gridUnit }
            KQControls.ColorButton {
                id: weatherPressureFontColor
                showAlphaChannel: false
                onAccepted: cfg_weather_pressure_font_color = color
            }
        }

        Kirigami.Separator { Layout.fillWidth: true; Layout.topMargin: Kirigami.Units.largeSpacing }

        Button {
            text: i18n("Reset to Defaults")
            Layout.alignment: Qt.AlignHCenter
            icon.name: "edit-undo"
            onClicked: {
                cfg_show_day = true
                cfg_day_font_size = 65
                cfg_day_font_color = "#FFFFFF"
                cfg_day_letter_spacing = 17
                cfg_show_time = true
                cfg_time_font_size = 85
                cfg_time_font_color = "#FFFFFF"
                cfg_time_ampm_color = "#FFFFFF"
                cfg_use_24_hour_format = false
                cfg_show_date_day = true
                cfg_date_day_font_size = 45
                cfg_date_day_font_color = "#FFFFFF"
                cfg_show_date_month = true
                cfg_date_month_font_size = 35
                cfg_date_month_font_color = "#FFFFFF"
                cfg_show_date_year = true
                cfg_date_year_font_size = 32
                cfg_date_year_font_color = "#FFFFFF"
                cfg_show_weather = true
                plasmoid.configuration.weather_latitude = 41.3874
                plasmoid.configuration.weather_longitude = 2.1686
                plasmoid.configuration.weather_city_name = "Barcelona, Spain"
                plasmoid.configuration.weather_location_set = true
                searchModel.clear()
                citySearch.text = ""
                cfg_weather_temp_color = "#FFFFFF"
                cfg_weather_icon_color = "#FFFFFF"
                cfg_weather_font_size = 16
                cfg_weather_use_celsius = true
                cfg_weather_show_city = true
                cfg_weather_city_font_size = 12
                cfg_weather_city_font_color = "#FFFFFF"
                cfg_weather_show_condition = true
                cfg_weather_condition_font_size = 11
                cfg_weather_condition_font_color = "#FFFFFF"
                cfg_weather_show_feelslike = true
                cfg_weather_feelslike_font_size = 11
                cfg_weather_feelslike_font_color = "#FFFFFF"
                cfg_weather_show_humidity = true
                cfg_weather_humidity_font_size = 11
                cfg_weather_humidity_font_color = "#FFFFFF"
                cfg_weather_show_wind = false
                cfg_weather_wind_font_size = 11
                cfg_weather_wind_font_color = "#FFFFFF"
                cfg_weather_show_pressure = false
                cfg_weather_pressure_font_size = 11
                cfg_weather_pressure_font_color = "#FFFFFF"
            }
        }

        Item { height: Kirigami.Units.largeSpacing }
    }
}
