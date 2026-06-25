import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {
    id: langPage

    property alias cfg_date_locale_override: localeCombo.currentValue

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            text: i18n("Language")
            level: 2
        }

        Label {
            text: i18n("Choose the language for day names, month names, and AM/PM text. Select \"System default\" to use your system language.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Label { text: i18n("Language") }
            ComboBox {
                id: localeCombo
                textRole: "label"
                valueRole: "code"
                Layout.fillWidth: true
                model: ListModel {
                    ListElement { label: "System default"; code: "" }
                    ListElement { label: "English"; code: "en_US" }
                    ListElement { label: "Spanish (Español)"; code: "es_ES" }
                    ListElement { label: "French (Français)"; code: "fr_FR" }
                    ListElement { label: "German (Deutsch)"; code: "de_DE" }
                    ListElement { label: "Italian (Italiano)"; code: "it_IT" }
                    ListElement { label: "Portuguese (Português)"; code: "pt_PT" }
                    ListElement { label: "Brazilian Portuguese (Português BR)"; code: "pt_BR" }
                    ListElement { label: "Dutch (Nederlands)"; code: "nl_NL" }
                    ListElement { label: "Russian (Русский)"; code: "ru_RU" }
                    ListElement { label: "Polish (Polski)"; code: "pl_PL" }
                    ListElement { label: "Swedish (Svenska)"; code: "sv_SE" }
                    ListElement { label: "Norwegian (Norsk)"; code: "nb_NO" }
                    ListElement { label: "Danish (Dansk)"; code: "da_DK" }
                    ListElement { label: "Finnish (Suomi)"; code: "fi_FI" }
                    ListElement { label: "Czech (Čeština)"; code: "cs_CZ" }
                    ListElement { label: "Romanian (Română)"; code: "ro_RO" }
                    ListElement { label: "Turkish (Türkçe)"; code: "tr_TR" }
                    ListElement { label: "Japanese (日本語)"; code: "ja_JP" }
                    ListElement { label: "Chinese Simplified (简体中文)"; code: "zh_CN" }
                    ListElement { label: "Chinese Traditional (繁體中文)"; code: "zh_TW" }
                    ListElement { label: "Korean (한국어)"; code: "ko_KR" }
                    ListElement { label: "Arabic (العربية)"; code: "ar_SA" }
                }
            }
        }

        Item { height: Kirigami.Units.largeSpacing }
    }
}
