import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

// Notification history center, top-right. Hides the popup stack while open.
PanelWindow {
    id: center

    required property var modelData
    property var theme
    property var notif
    property var nc
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
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    visible: nc.open
    implicitWidth: 340

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        width: 340
        height: col.implicitHeight + 20
        color: theme.c.bg
        border.color: theme.c.border
        border.width: 2
        radius: 2

        ColumnLayout {
            id: col

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "通知 CENTER"
                    color: theme.c.accent
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: "transparent"
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitWidth: 64
                    implicitHeight: 22

                    Text {
                        anchors.centerIn: parent
                        text: "CLEAR"
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notif.clearAll()
                    }
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
                        onClicked: nc.close()
                    }
                }
            }

            Text {
                visible: notif.items.length === 0
                text: "通知なし — NO NOTIFICATIONS"
                color: theme.c.dim
                font.family: theme.font
                font.pixelSize: theme.fs - 1
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Repeater {
                model: notif.items

                delegate: Rectangle {
                    required property var modelData

                    color: theme.c.panel
                    border.color: modelData.urgency === NotificationUrgency.Critical ? theme.c.accent : theme.c.dim
                    border.width: 1
                    radius: 2
                    implicitWidth: 320
                    implicitHeight: rowCol.implicitHeight + 12
                    Layout.fillWidth: true

                    ColumnLayout {
                        id: rowCol

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 6
                        spacing: 1

                        Text {
                            text: (modelData.appName || "SYSTEM").toUpperCase()
                            color: theme.c.dim
                            font.family: theme.font
                            font.pixelSize: theme.fs - 3
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.summary || ""
                            color: theme.c.fg
                            font.family: theme.font
                            font.pixelSize: theme.fs - 1
                            font.bold: true
                            textFormat: Text.PlainText
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: (modelData.body || "") !== ""
                            text: modelData.body || ""
                            color: theme.c.fg
                            font.family: theme.font
                            font.pixelSize: theme.fs - 2
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notif.dismiss(modelData)
                    }
                }
            }
        }

        Grain {
            anchors.fill: parent
        }
    }
}
