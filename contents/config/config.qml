import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Language")
        icon: "preferences-desktop-locale"
        source: "configLang.qml"
    }
    ConfigCategory {
        name: i18n("Units")
        icon: "office-chart-bar"
        source: "configUnits.qml"
    }
}
