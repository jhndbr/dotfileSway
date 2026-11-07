import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../components"
import "../.."

PanelWindow {
    id: root

    property bool isOpen: false
    visible: isOpen || slideAnim.running
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:ai-sidebar"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property bool busy: false
    property int activeAssistantIndex: -1
    property string statusText: "Gemini 3.8 Flash Low"

    function toggle(): void {
        isOpen = !isOpen;
        if (isOpen) {
            Qt.callLater(() => input.forceActiveFocus());
        }
    }

    function show(): void {
        isOpen = true;
        Qt.callLater(() => input.forceActiveFocus());
    }

    function hide(): void {
        isOpen = false;
    }

    onIsOpenChanged: {
        if (isOpen) {
            Qt.callLater(() => input.forceActiveFocus());
        }
    }

    ListModel {
        id: messages
    }

    function sendMessage(customPrompt) {
        const prompt = (customPrompt !== undefined ? customPrompt : input.text).trim();
        if (!prompt || busy) return;

        if (!backend.running) {
            statusText = "El backend no está ejecutándose";
            return;
        }

        messages.append({
            role: "user",
            text: prompt
        });

        messages.append({
            role: "assistant",
            text: ""
        });

        activeAssistantIndex = messages.count - 1;
        busy = true;
        statusText = "Pensando…";

        const payload = {
            event: "user",
            message: {
                content: prompt
            }
        };

        backend.write(JSON.stringify(payload) + "\n");
        input.clear();
        messageList.positionViewAtEnd();
    }

    function handleAgentEvent(line) {
        if (!line || !line.trim()) return;

        let event;
        try {
            event = JSON.parse(line);
        } catch (error) {
            console.warn("[Antigravity Chat] Evento JSON inválido:", line);
            return;
        }

        if (event.event === "init") {
            statusText = "Conectado · Gemini 3.8 Flash Low";
            return;
        }

        if (event.event === "step_update") {
            const update = event.step_update;
            if (update && update.text_delta !== undefined && activeAssistantIndex >= 0) {
                const current = messages.get(activeAssistantIndex).text;
                messages.setProperty(
                    activeAssistantIndex,
                    "text",
                    current + update.text_delta
                );
                messageList.positionViewAtEnd();
            }
            return;
        }

        if (event.event === "result") {
            const result = event.result || {};

            if (activeAssistantIndex >= 0) {
                const current = messages.get(activeAssistantIndex).text;
                if (result.status !== "SUCCESS") {
                    messages.setProperty(
                        activeAssistantIndex,
                        "text",
                        current + "\n\nError: " +
                        (result.error || result.status || "Error desconocido")
                    );
                } else if (!current && result.response) {
                    messages.setProperty(
                        activeAssistantIndex,
                        "text",
                        result.response
                    );
                }
            }

            busy = false;
            activeAssistantIndex = -1;
            statusText = "Gemini 3.8 Flash Low";
            input.forceActiveFocus();
            messageList.positionViewAtEnd();
            return;
        }

        if (event.event === "bridge_error") {
            statusText = event.message || "Error en el backend";
            if (activeAssistantIndex >= 0) {
                messages.setProperty(
                    activeAssistantIndex,
                    "text",
                    "Error: " + statusText
                );
            }
            busy = false;
            activeAssistantIndex = -1;
        }
    }

    IpcHandler {
        target: "antigravityChat"

        function toggle(): void {
            root.toggle();
        }

        function show(): void {
            root.show();
        }

        function hide(): void {
            root.hide();
        }
    }

    Process {
        id: backend

        command: [
            "python3",
            Qt.resolvedUrl("Agent.py").toString().replace("file://", "")
        ]

        running: true
        stdinEnabled: true

        stdout: SplitParser {
            onRead: data => root.handleAgentEvent(data)
        }

        stderr: SplitParser {
            onRead: data => console.warn("[Antigravity Process]", data)
        }

        onExited: (exitCode, exitStatus) => {
            root.busy = false;
            root.statusText = "Backend detenido (" + exitCode + ")";
        }
    }

    // Transparent Backdrop (Dismiss on click outside without darkening desktop)
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            enabled: root.isOpen
            onClicked: root.hide()
        }
    }

    // ==========================================
    // Sleek Sliding Sidebar Panel (Liquid Glass Transparente)
    // ==========================================
    Rectangle {
        id: sidebarCard
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        anchors.topMargin: Config.barPosition === "top" ? (Config.floatingBar ? Config.barHeight + 8 : Config.barHeight + 2) : 0
        anchors.bottomMargin: Config.dockEnabled ? (Config.dockAutoHide ? 0 : Config.dockHeight + 8) : 0
        anchors.rightMargin: 8

        width: Math.min(parent.width * 0.9, 420)
        radius: Theme.radiusMd

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1
        clip: true

        // Smooth Slide-in / Slide-out Animation from the right edge
        transform: Translate {
            id: slideTrans
            x: root.isOpen ? 0 : (sidebarCard.width + 20)

            Behavior on x {
                NumberAnimation {
                    id: slideAnim
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Consume clicks so they don't dismiss the sidebar
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Top Header Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Gemini Sparkle Logo Badge
                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 10
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20)
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.50)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✦"
                        color: Theme.accent
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                // Title & Online Status
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Antigravity AI"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 5

                        // Status dot indicator
                        Rectangle {
                            implicitWidth: 6
                            implicitHeight: 6
                            radius: 3
                            color: root.busy ? Theme.accent : "#4ade80"
                            SequentialAnimation on opacity {
                                running: root.busy
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 400 }
                                NumberAnimation { to: 1.0; duration: 400 }
                            }
                        }

                        Text {
                            text: root.statusText
                            color: root.busy ? Theme.accent : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }

                // Limpiar Historial Button
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 8
                    color: cleanMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰃢"
                        size: 13
                        color: cleanMouse.containsMouse ? Theme.accent : Theme.textMuted
                    }

                    MouseArea {
                        id: cleanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!root.busy) messages.clear();
                        }
                    }
                }

                // Close Button
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 8
                    color: closeMouse.containsMouse ? Theme.danger : Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeMouse.containsMouse ? "#ffffff" : Theme.text
                        font.pixelSize: 18
                        font.bold: true
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.hide()
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.separator
            }

            // Messages ListView
            ListView {
                id: messageList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10
                model: messages
                boundsBehavior: Flickable.StopAtBounds

                onCountChanged: positionViewAtEnd()

                delegate: Item {
                    id: messageDelegate
                    required property string role
                    required property string text
                    required property int index

                    width: ListView.view.width
                    height: bubble.implicitHeight + 4

                    Rectangle {
                        id: bubble
                        anchors.left: messageDelegate.role === "user" ? undefined : parent.left
                        anchors.right: messageDelegate.role === "user" ? parent.right : undefined
                        anchors.leftMargin: messageDelegate.role === "user" ? 36 : 0
                        anchors.rightMargin: messageDelegate.role === "user" ? 0 : 36
                        width: Math.min(parent.width * 0.88, msgText.implicitWidth + 24)
                        implicitHeight: msgText.implicitHeight + 18
                        radius: 12

                        color: messageDelegate.role === "user"
                               ? Qt.rgba(Theme.accentColor.r, Theme.accentColor.g, Theme.accentColor.b, 0.28)
                               : Theme.fillPrimary
                        border.color: messageDelegate.role === "user"
                                     ? Theme.accentColor
                                     : Theme.specularBorder
                        border.width: 1

                        Text {
                            id: msgText
                            anchors.fill: parent
                            anchors.margins: 10
                            text: messageDelegate.text || (messageDelegate.role === "assistant" && root.busy && root.activeAssistantIndex === messageDelegate.index ? "…" : "")
                            color: Theme.labelPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            textFormat: Text.PlainText
                            lineHeight: 1.25
                        }
                    }
                }

                // Onboarding Greeting & Quick Prompt Chips when empty
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: messages.count === 0
                    spacing: 12
                    width: parent.width - 32

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "✦"
                        color: Theme.accent
                        font.pixelSize: 32
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "¿En qué puedo ayudarte?"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Asistente inteligente con Gemini CLI (agy)."
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }

                    Item { Layout.fillWidth: true; height: 8 }

                    // Quick Chips
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                "¿Cómo optimizo mi flujo en Sway?",
                                "Escribe un script en Python para automatizar tareas",
                                "¿Qué herramientas CLI tengo disponibles?"
                            ]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 32
                                radius: 8
                                color: chipMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                                border.color: chipMouse.containsMouse ? Theme.accent : Theme.border
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 6

                                    Icon { glyph: "󰅂"; size: 11; color: Theme.accent }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData
                                        color: chipMouse.containsMouse ? Theme.accent : Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: chipMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.sendMessage(modelData)
                                }
                            }
                        }
                    }
                }
            }

            // Input Bar Container
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: Theme.fillTertiary
                border.color: input.activeFocus ? Theme.accentColor : Theme.specularBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 6
                    spacing: 8

                    TextField {
                        id: input
                        Layout.fillWidth: true
                        placeholderText: root.busy ? "Esperando a Gemini…" : "Pregúntale a Gemini..."
                        enabled: !root.busy
                        color: Theme.text
                        placeholderTextColor: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        selectByMouse: true
                        background: Item {}

                        onAccepted: root.sendMessage()

                        Keys.onEscapePressed: {
                            if (text.length > 0) {
                                clear();
                            } else {
                                root.hide();
                            }
                        }
                    }

                    // Enviar Button
                    Rectangle {
                        implicitWidth: 34
                        implicitHeight: 34
                        radius: 8
                        color: (!root.busy && input.text.trim().length > 0) ? (sendMouse.containsMouse ? Theme.accentHover : Theme.accent) : Theme.surfaceHover
                        opacity: (!root.busy && input.text.trim().length > 0) ? 1.0 : 0.4

                        Icon {
                            anchors.centerIn: parent
                            glyph: "󰒭"
                            size: 14
                            color: (!root.busy && input.text.trim().length > 0) ? Theme.bgSolid : Theme.textMuted
                        }

                        MouseArea {
                            id: sendMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.busy && input.text.trim().length > 0
                            onClicked: root.sendMessage()
                        }
                    }
                }
            }

            // Footer hint
            Text {
                Layout.fillWidth: true
                text: "Enter para enviar · Esc para cerrar panel"
                color: Qt.rgba(255, 255, 255, 0.35)
                font.family: Theme.fontFamily
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
