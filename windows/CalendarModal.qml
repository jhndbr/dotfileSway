import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import ".."

PanelWindow {
    id: calWindow

    property bool isOpen: false

    visible: isOpen
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "swayshell:calendar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Dismiss on click outside
    MouseArea {
        anchors.fill: parent
        onClicked: {
            calWindow.isOpen = false;
        }
    }

    // Soft floating drop shadow behind Calendar card
    Rectangle {
        id: calShadow
        anchors.fill: calCard
        anchors.margins: -4
        anchors.topMargin: -1
        anchors.bottomMargin: -6
        radius: Theme.cardRadius + 4
        color: Qt.rgba(0, 0, 0, 0.35)
        z: 0
    }

    // Floating Calendar Card (anchored beneath menubar)
    Rectangle {
        id: calCard
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 8
        width: 300
        implicitHeight: calCol.implicitHeight + 28
        radius: Theme.cardRadius

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.glassMediumTop }
            GradientStop { position: 1.0; color: Theme.glassMediumBottom }
        }
        border.color: Theme.specularBorder
        border.width: 1

        // Prevent click-through dismissal
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        property var displayDate: new Date()
        readonly property int displayYear: displayDate.getFullYear()
        readonly property int displayMonth: displayDate.getMonth()
        readonly property string displayMonthName: {
            const months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
            return months[displayMonth] + " " + displayYear;
        }

        function prevMonth() {
            displayDate = new Date(displayYear, displayMonth - 1, 1);
        }
        function nextMonth() {
            displayDate = new Date(displayYear, displayMonth + 1, 1);
        }
        function resetToToday() {
            displayDate = new Date();
        }

        ColumnLayout {
            id: calCol
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Header: Month & Year + Navigation
            RowLayout {
                Layout.fillWidth: true

                Text {
                    id: headerText
                    Layout.fillWidth: true
                    text: calCard.displayMonthName
                    color: Theme.accentColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeRegular + 1
                    font.weight: Font.DemiBold
                }

                // Month Navigation Buttons (< and >)
                RowLayout {
                    spacing: 3

                    Rectangle {
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 4
                        color: prevCalMouse.containsMouse ? Theme.surfaceHover : "transparent"
                        Icon { anchors.centerIn: parent; glyph: "󰅁"; size: 12; color: Theme.textPrimary }
                        MouseArea {
                            id: prevCalMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calCard.prevMonth()
                        }
                    }

                    Rectangle {
                        implicitWidth: 38
                        implicitHeight: 22
                        radius: 4
                        color: todayCalMouse.containsMouse ? Theme.surfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "Hoy"
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                        MouseArea {
                            id: todayCalMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calCard.resetToToday()
                        }
                    }

                    Rectangle {
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 4
                        color: nextCalMouse.containsMouse ? Theme.surfaceHover : "transparent"
                        Icon { anchors.centerIn: parent; glyph: "󰅂"; size: 12; color: Theme.textPrimary }
                        MouseArea {
                            id: nextCalMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calCard.nextMonth()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.separatorColor
            }

            // Days of week header
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: ["Lu", "Ma", "Mi", "Ju", "Vi", "Sá", "Do"]

                    delegate: Item {
                        required property string modelData
                        Layout.fillWidth: true
                        implicitHeight: 20

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            // Days grid for current month
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 0

                readonly property var calendarInfo: {
                    const now = new Date();
                    const isThisMonth = now.getFullYear() === calCard.displayYear && now.getMonth() === calCard.displayMonth;
                    const today = now.getDate();

                    const firstDayIndex = (new Date(calCard.displayYear, calCard.displayMonth, 1).getDay() + 6) % 7;
                    const totalDays = new Date(calCard.displayYear, calCard.displayMonth + 1, 0).getDate();

                    const days = [];
                    for (let i = 0; i < firstDayIndex; i++) {
                        days.push({ day: 0, isCurrentMonth: false, isToday: false });
                    }
                    for (let d = 1; d <= totalDays; d++) {
                        days.push({ day: d, isCurrentMonth: true, isToday: isThisMonth && d === today });
                    }
                    return days;
                }

                Repeater {
                    model: parent.calendarInfo

                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 24

                        Rectangle {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            radius: 11
                            color: modelData.isToday ? Theme.accentColor : (dayMouse.containsMouse && modelData.day > 0 ? Theme.surfaceHover : "transparent")
                            visible: modelData.day > 0

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day > 0 ? String(modelData.day) : ""
                                color: modelData.isToday ? Theme.bgSolid : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.weight: modelData.isToday ? Font.Bold : Font.Normal
                            }

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }
    }
}
