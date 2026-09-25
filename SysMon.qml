import Quickshell
import QtQuick
import QtQuick.Layouts

// SysMon dropdown: same data as the bar, large, with segment bars + extras.
// Closes via X, stats-capsule toggle, Mod+Esc (ipc) or 8s autohide (paused on hover).
PanelWindow {
    id: sysmon

    required property var modelData
    property var theme
    property var sys
    property var state
    property var cc

    screen: modelData

    anchors {
        top: true
        right: true
    }
    margins {
        top: theme.barHeight + 8 + (cc.open ? 370 : 0)
        right: 10
    }
    implicitWidth: 340
    implicitHeight: col.implicitHeight + 20
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    visible: state.open

    onVisibleChanged: {
        if (visible)
            hideTimer.restart();
        else
            hideTimer.stop();
    }

    property Timer hideTimer: Timer {
        interval: 8000
        onTriggered: state.close()
    }

    Rectangle {
        anchors.fill: parent
        color: theme.c.bg
        border.color: theme.c.border
        border.width: 2
        radius: 2

        // hover pauses autohide (below content in z-order so X still clickable)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: hideTimer.stop()
            onExited: {
                if (state.open)
                    hideTimer.restart();
            }
        }

        ColumnLayout {
            id: col

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "監視 SYSMON"
                    color: theme.c.accent
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: "transparent"
                    border.color: theme.c.dim
                    border.width: 1
                    radius: 2
                    implicitWidth: 26
                    implicitHeight: 22

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: state.close()
                    }
                }
            }

            Repeater {
                model: [
                    { "l": "CPU", "v": sys.cpu, "c": theme.c.accent, "s": "%" },
                    { "l": "MEM", "v": sys.mem, "c": theme.c.accent2, "s": "%" },
                    { "l": "TEMP", "v": sys.temp, "c": theme.c.accent, "s": "°C" },
                    { "l": "BAT", "v": sys.bat === "AC" ? 100 : (parseInt(sys.bat, 10) || 0), "c": theme.c.accent2, "s": sys.bat === "AC" ? " AC" : "%" },
                    { "l": "VOL", "v": sys.vol, "c": theme.c.accent, "s": "%" },
                    { "l": "BRI", "v": sys.bri, "c": theme.c.accent2, "s": "%" },
                    { "l": "DISK", "v": sys.disk, "c": theme.c.accent, "s": "%" }
                ]

                delegate: ColumnLayout {
                    id: rowDel

                    required property var modelData

                    Layout.fillWidth: true
                    spacing: 3

                    property int lit: Math.max(0, Math.min(20, Math.round((modelData.v / 100) * 20)))

                    Text {
                        text: modelData.l + "  " + modelData.v + modelData.s
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Row {
                        spacing: 2
                        Layout.fillWidth: true

                        Repeater {
                            model: 20

                            delegate: Rectangle {
                                required property int index

                                width: 12
                                height: 14
                                radius: 1
                                color: index < rowDel.lit ? rowDel.modelData.c : "transparent"
                                border.color: index < rowDel.lit ? "transparent" : theme.c.dim
                                border.width: index < rowDel.lit ? 0 : 1
                            }
                        }
                    }
                }
            }

            Text {
                text: "LOAD " + sys.load.replace(/,/g, " ") + "   UP " + sys.uptime
                color: theme.c.dim
                font.family: theme.font
                font.pixelSize: theme.fs - 1
                Layout.fillWidth: true
            }
        }

        Grain {
            anchors.fill: parent
        }
    }
}
