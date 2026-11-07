import QtQuick
import ".."

Rectangle {
    id: root

    property color cardBg: Theme.glassMediumTop
    property color cardBorder: Theme.specularBorder
    property int cardRadius: Theme.cardRadius
    property bool showSpecularRim: true

    radius: cardRadius
    border.color: cardBorder
    border.width: 1

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: root.cardBg
        }
        GradientStop {
            position: 1.0
            color: Theme.glassMediumBottom
        }
    }

    Behavior on border.color {
        ColorAnimation { duration: Theme.animNormal; easing.type: Theme.animEasing }
    }
}
