// contents/config/config.qml
import QtQuick 2.15
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        id: configCategory
        name: i18n("General")
        icon: "configure"
        source: "../ui/config/ConfigGeneral.qml"
    }
}