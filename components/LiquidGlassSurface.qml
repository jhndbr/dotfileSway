import QtQuick
import ".."

/**
 * LiquidGlassSurface.qml
 * Superficie translúcida oficial Apple Liquid Glass (iOS 27 / macOS Tahoe).
 * Recrea fielmente la estética y física óptica del kit de diseño de Apple
 * sin utilizar shaders de desenfoque/blur, manteniendo 60+ FPS constante y bajo consumo de recursos.
 */
Rectangle {
    id: root

    // Variantes de escala: "small" (cápsulas, botones), "medium" (paneles, popovers), "bar" (barra superior), "dock" (dock)
    property string variant: "small"

    // Radio de esquinas: En "small", píldora completa (height / 2) por defecto
    property int cornerRadius: {
        if (variant === "small") return height / 2;
        if (variant === "bar") return Config.floatingBar ? Theme.radiusMd : 0;
        if (variant === "dock") return Theme.dockRadius;
        return Theme.cardRadius;
    }

    // Estados de interacción
    property bool interactive: false
    property bool hovered: false
    property bool active: false

    // Control del micro-bisel especular superior (desactivado en small para evitar barras blancas en botones)
    property bool showSpecularRim: variant !== "small"
    property real specularIntensity: 1.0

    // Colores de gradiente personalizados opcionales
    property color customTopColor: "transparent"
    property color customBottomColor: "transparent"

    radius: cornerRadius
    border.width: 1
    border.color: {
        if (root.active) return Theme.accentColor;
        if (root.hovered) return Theme.specularBorderHover;
        return Theme.specularBorder;
    }

    Behavior on border.color {
        ColorAnimation { duration: Theme.animFast }
    }

    // Gradiente refractivo vertical con canal alfa calibrado
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: {
                if (root.customTopColor !== "transparent") return root.customTopColor;
                if (root.active) return Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.40);
                if (root.hovered) return Qt.lighter(Theme.glassSmallTop, 1.20);
                if (root.variant === "small") return Theme.glassSmallTop;
                if (root.variant === "bar") return Theme.glassBarTop;
                if (root.variant === "dock") return Theme.glassDock;
                return Theme.glassMediumTop;
            }
        }
        GradientStop {
            position: 1.0
            color: {
                if (root.customBottomColor !== "transparent") return root.customBottomColor;
                if (root.active) return Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.22);
                if (root.hovered) return Qt.lighter(Theme.glassSmallBottom, 1.20);
                if (root.variant === "small") return Theme.glassSmallBottom;
                if (root.variant === "bar") return Theme.glassBarBottom;
                if (root.variant === "dock") return Theme.glassDock;
                return Theme.glassMediumBottom;
            }
        }
    }

    // Micro-reflejo especular superior (Plus Lighter top rim)
    Rectangle {
        id: specularRim
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(0, parent.width - parent.radius * 1.1)
        height: 1
        color: Theme.specularTopRim
        antialiasing: true
        opacity: root.showSpecularRim ? root.specularIntensity : 0.0
        visible: root.showSpecularRim && width > 4
    }
}
