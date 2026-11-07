import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"
import ".."

BasePill {
    id: root

    visible: Config.showBrightness && BrightnessService.available
    implicitHeight: Theme.barHeight - 8
    implicitWidth: brightRow.implicitWidth + 16
    clickable: true

    readonly property string iconGlyph: {
        if (BrightnessService.brightnessPercent >= 70) return "󰃠";
        if (BrightnessService.brightnessPercent >= 30) return "󰃟";
        return "󰃞";
    }

    onScrolled: (delta) => {
        if (delta > 0) {
            BrightnessService.increaseBrightness(0.05);
        } else if (delta < 0) {
            BrightnessService.decreaseBrightness(0.05);
        }
    }

    RowLayout {
        id: brightRow
        anchors.centerIn: parent
        spacing: 6

        Icon {
            glyph: root.iconGlyph
            color: Theme.accentSecondary
            size: 14
        }

        Text {
            text: BrightnessService.brightnessPercent + "%"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
