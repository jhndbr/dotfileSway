import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int implicitSize: 22
    property int lineWidth: 2
    property real value: 0
    property color colPrimary: "#cba6f7"
    property color colSecondary: Qt.rgba(colPrimary.r, colPrimary.g, colPrimary.b, 0.22)
    property bool enableAnimation: true
    property int animationDuration: 300
    property var easingType: Easing.OutQuad

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    property real degree: Math.max(0.0, Math.min(1.0, value)) * 360
    property real centerX: root.width / 2
    property real centerY: root.height / 2
    property real arcRadius: Math.max(1, root.implicitSize / 2 - root.lineWidth)
    property real startAngle: -90

    Behavior on degree {
        enabled: root.enableAnimation
        NumberAnimation {
            duration: root.animationDuration
            easing.type: root.easingType
        }
    }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer

        // Background Track Ring
        ShapePath {
            strokeColor: root.colSecondary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Animated Foreground Progress Arc
        ShapePath {
            strokeColor: root.colPrimary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle
                sweepAngle: Math.max(0.1, root.degree)
            }
        }
    }
}
