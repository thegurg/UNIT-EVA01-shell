import Quickshell
import QtQuick
import QtQuick.Layouts

// Top full-width bar, Exodia-flavoured segments. Label click = next theme,
// power glyph toggles the Control Center.
PanelWindow {
    id: bar

    required property var modelData
    property var theme
    property var niri
    property var sys
    property var cc
    property var mon
    property var notif
    property var nc
    property var pstate
    property var wifi
    property var bt

    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: theme.barHeight
    exclusiveZone: theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: theme.c.bg

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: theme.c.accent
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 6
            anchors.bottomMargin: 6
            spacing: 8

            // theme label capsule, click = next theme
            Rectangle {
                color: theme.c.panel
                border.color: theme.c.border
                border.width: 1
                radius: 2
                implicitHeight: theme.segHeight
                implicitWidth: themeLabel.width + 16
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: themeLabel

                    anchors.centerIn: parent
                    text: "▮" + theme.c.label
                    color: theme.c.accent
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: theme.next()
                }
            }

            Workspaces {
                theme: bar.theme
                niri: bar.niri
                Layout.alignment: Qt.AlignVCenter
            }

            WindowTitle {
                theme: bar.theme
                niri: bar.niri
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            Player {
                theme: bar.theme
                pstate: bar.pstate
                panels: ({ "cc": bar.cc, "nc": bar.nc, "mon": bar.mon, "wifi": bar.wifi, "bt": bar.bt })
                Layout.alignment: Qt.AlignVCenter
            }

            SysStats {
                theme: bar.theme
                sys: bar.sys
                mon: bar.mon
                panels: ({ "cc": bar.cc, "nc": bar.nc, "pstate": bar.pstate, "wifi": bar.wifi, "bt": bar.bt })
                Layout.alignment: Qt.AlignVCenter
            }

            Clock {
                theme: bar.theme
                Layout.alignment: Qt.AlignVCenter
            }

            // wifi panel opener
            Rectangle {
                color: wifi.open ? theme.c.accent : theme.c.panel
                border.color: theme.c.border
                border.width: 1
                radius: 2
                implicitHeight: theme.segHeight
                implicitWidth: 46
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: "WIFI"
                    color: wifi.open ? theme.c.bg : theme.c.fg
                    font.family: theme.font
                    font.pixelSize: theme.fs - 2
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wifi.toggle();
                        if (wifi.open) {
                            cc.close();
                            bt.close();
                            nc.close();
                            mon.close();
                            pstate.close();
                        }
                    }
                }
            }

            // bluetooth panel opener
            Rectangle {
                color: bt.open ? theme.c.accent : theme.c.panel
                border.color: theme.c.border
                border.width: 1
                radius: 2
                implicitHeight: theme.segHeight
                implicitWidth: 34
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: "BT"
                    color: bt.open ? theme.c.bg : theme.c.fg
                    font.family: theme.font
                    font.pixelSize: theme.fs - 2
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        bt.toggle();
                        if (bt.open) {
                            cc.close();
                            wifi.close();
                            nc.close();
                            mon.close();
                            pstate.close();
                        }
                    }
                }
            }

            // notification blinker (no icon): pulses while unread > 0
            Rectangle {
                color: nc.open ? theme.c.accent : theme.c.panel
                border.color: theme.c.border
                border.width: 1
                radius: 2
                implicitHeight: theme.segHeight
                implicitWidth: bellRow.width + 16
                Layout.alignment: Qt.AlignVCenter

                Row {
                    id: bellRow

                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        id: blink

                        width: 10
                        height: 10
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: nc.open ? theme.c.bg : (notif.unread > 0 ? theme.c.accent : theme.c.dim)
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: String(notif.unread)
                        color: nc.open ? theme.c.bg : theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs
                        font.bold: true
                    }
                }

                Timer {
                    interval: 500
                    repeat: true
                    running: notif.unread > 0 && !nc.open
                    triggeredOnStart: true
                    onTriggered: blink.opacity = blink.opacity > 0.5 ? 0.15 : 1.0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        nc.toggle();
                        if (nc.open) {
                            notif.markRead();
                            cc.close();
                            mon.close();
                            pstate.close();
                            wifi.close();
                            bt.close();
                        }
                    }
                }
            }

            // control center toggle
            Rectangle {
                color: cc.open ? theme.c.accent : theme.c.panel
                border.color: theme.c.border
                border.width: 1
                radius: 2
                implicitHeight: theme.segHeight
                implicitWidth: 34
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    color: cc.open ? theme.c.bg : theme.c.fg
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        cc.toggle();
                        if (cc.open) {
                            nc.close();
                            mon.close();
                            pstate.close();
                            wifi.close();
                            bt.close();
                        }
                    }
                }
            }
        }

        Grain {
            anchors.fill: parent
        }
    }
}
