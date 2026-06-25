import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {
    id: unitsPage

    property alias cfg_weather_temperature_unit: tempCombo.currentValue
    property alias cfg_weather_wind_unit: windCombo.currentValue
    property alias cfg_weather_pressure_unit: pressureCombo.currentValue

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            text: i18n("Units")
            level: 2
        }

        Label {
            text: i18n("Choose measurement units for weather data. Defaults follow your system locale.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Label { text: i18n("Temperature"); Layout.minimumWidth: Kirigami.Units.gridUnit * 6 }
            ComboBox {
                id: tempCombo
                textRole: "label"
                valueRole: "code"
                Layout.fillWidth: true
                model: ListModel {
                    ListElement { label: qsTr("Celsius"); code: "celsius" }
                    ListElement { label: qsTr("Fahrenheit"); code: "fahrenheit" }
                    ListElement { label: qsTr("Kelvin"); code: "kelvin" }
                }
            }
        }

        RowLayout {
            Label { text: i18n("Wind Speed"); Layout.minimumWidth: Kirigami.Units.gridUnit * 6 }
            ComboBox {
                id: windCombo
                textRole: "label"
                valueRole: "code"
                Layout.fillWidth: true
                model: ListModel {
                    ListElement { label: qsTr("km/h"); code: "kmh" }
                    ListElement { label: qsTr("mph"); code: "mph" }
                    ListElement { label: qsTr("m/s"); code: "ms" }
                    ListElement { label: qsTr("knots"); code: "knots" }
                }
            }
        }

        RowLayout {
            Label { text: i18n("Pressure"); Layout.minimumWidth: Kirigami.Units.gridUnit * 6 }
            ComboBox {
                id: pressureCombo
                textRole: "label"
                valueRole: "code"
                Layout.fillWidth: true
                model: ListModel {
                    ListElement { label: qsTr("hPa"); code: "hpa" }
                    ListElement { label: qsTr("inHg"); code: "inhg" }
                    ListElement { label: qsTr("mmHg"); code: "mmhg" }
                }
            }
        }

        Item { height: Kirigami.Units.largeSpacing }
    }
}
