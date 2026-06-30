import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kquickcontrols as KQControls

RowLayout {
    id: root
    property var color
    property string label: i18n("Font Color")

    Label {
        text: root.label
    }
    KQControls.ColorButton {
        id: colorbutton
        color: root.color
        showAlphaChannel: false
        onAccepted: root.color = color
    }
}
