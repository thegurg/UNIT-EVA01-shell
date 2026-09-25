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

            SysStats {
                theme: bar.theme
                sys: bar.sys
                Layout.alignment: Qt.AlignVCenter
            }

            Clock {
                theme: bar.theme
                Layout.alignment: Qt.AlignVCenter
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
                    onClicked: cc.toggle()
                }
            }
        }
    }
}
