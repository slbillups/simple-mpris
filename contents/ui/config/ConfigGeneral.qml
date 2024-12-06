import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: page

    property string cfg_artist: "Unknown Artist"
    property string cfg_track: "Unknown Track"
    property string title: "Simple MPRIS Configuration"

    property int cfg_volumeOverlayAlignmentDefault: Text.AlignLeft
    property int cfg_timeOverlayAlignmentDefault: Text.AlignLeft
    property bool cfg_volumeTextBoldDefault: false
    property bool cfg_volumeTextItalicDefault: false 
    property bool cfg_volumeTextUnderlineDefault: false
    property bool cfg_timeTextBoldDefault: false
    property bool cfg_timeTextItalicDefault: false
    property bool cfg_timeTextUnderlineDefault: false
    property bool cfg_transparentBackgroundEnabledDefault: false
    property int cfg_volumeOverlayPixelSizeDefault: 12
    property int cfg_timeOverlayPixelSizeDefault: 12

    property int shapeCircle: configCategory.data.shapeCircle
    property int shapeSquare: configCategory.data.shapeSquare

    // Volume Overlay
    property alias cfg_volumeOverlayAlignment: volumeAlign.currentValue
    property alias cfg_volumeOverlayPixelSize: volumePixelSize.value
    property alias cfg_volumeTextBold: volumeBold.checked
    property alias cfg_volumeTextItalic: volumeItalic.checked
    property alias cfg_volumeTextUnderline: volumeUnderline.checked

    // Time Overlay
    property alias cfg_timeOverlayAlignment: timeAlign.currentValue
    property alias cfg_timeOverlayPixelSize: timePixelSize.value
    property alias cfg_timeTextBold: timeBold.checked
    property alias cfg_timeTextItalic: timeItalic.checked
    property alias cfg_timeTextUnderline: timeUnderline.checked

    // Player Shape
    property alias cfg_playerShape: playerShape.currentValue

    // Transparent Background
    property alias cfg_transparentBackgroundEnabled: transparentBackground.checked

    ColumnLayout {
        Kirigami.FormData.label: i18n("Volume Overlay Format")
        QQC2.ComboBox {
            id: volumeAlign
            model: [
                {text: i18n("Left"), value: Text.AlignLeft},
                {text: i18n("Center"), value: Text.AlignHCenter},
                {text: i18n("Right"), value: Text.AlignRight}
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: cfg_volumeOverlayAlignment === Text.AlignLeft ? 0 :
                          cfg_volumeOverlayAlignment === Text.AlignHCenter ? 1 : 2
            onCurrentIndexChanged: plasmoid.configuration.volumeOverlayAlignment = model[currentIndex].value
        }
        QQC2.CheckBox { id: volumeBold; text: i18n("Bold") }
        QQC2.CheckBox { id: volumeItalic; text: i18n("Italic") }
        QQC2.CheckBox { id: volumeUnderline; text: i18n("Underline") }
        QQC2.SpinBox {
            id: volumePixelSize
            Kirigami.FormData.label: i18n("Font Size (px)")
            from: 12
            to: 48
            value: plasmoid.configuration.volumeOverlayPixelSize
        }
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Time Overlay Format")
        QQC2.ComboBox {
            id: timeAlign
            model: [
                {text: i18n("Left"), value: Text.AlignLeft},
                {text: i18n("Center"), value: Text.AlignHCenter},
                {text: i18n("Right"), value: Text.AlignRight}
            ]
            textRole: "text"
            valueRole: "value"
            currentIndex: cfg_timeOverlayAlignment === Text.AlignLeft ? 0 :
                          cfg_timeOverlayAlignment === Text.AlignHCenter ? 1 : 2
            onCurrentIndexChanged: plasmoid.configuration.timeOverlayAlignment = model[currentIndex].value
        }
        QQC2.CheckBox { id: timeBold; text: i18n("Bold") }
        QQC2.CheckBox { id: timeItalic; text: i18n("Italic") }
        QQC2.CheckBox { id: timeUnderline; text: i18n("Underline") }
        QQC2.SpinBox {
            id: timePixelSize
            Kirigami.FormData.label: i18n("Font Size (px)")
            from: 12
            to: 48
            value: plasmoid.configuration.timeOverlayPixelSize
        }
    }

    // Player Shape
    QQC2.ComboBox {
        id: playerShape
        Layout.fillWidth: true
        model: [
            {text: i18n("Circle"), value: shapeCircle},
            {text: i18n("Square"), value: shapeSquare}
        ]
        textRole: "text"
        valueRole: "value"

        // Use plasmoid.configuration for binding
        currentIndex: plasmoid.configuration.playerShape === shapeCircle ? 0 : 1
        onCurrentIndexChanged: plasmoid.configuration.playerShape = model[currentIndex].value
    }

    // Transparent Background
    QQC2.CheckBox {
        id: transparentBackground
        Kirigami.FormData.label: i18n("Background")
        text: i18n("Transparent")
        checked: plasmoid.configuration.transparentBackgroundEnabled
    }
}
