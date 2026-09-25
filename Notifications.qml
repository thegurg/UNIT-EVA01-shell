import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

// Top-right notification stack. Overlay, reserves no space.
PanelWindow {
    id: notifs

    required property var modelData
    property var theme
    property var notif
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

    visible: notif.items.length > 0
    implicitWidth: 330

    ColumnLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        width: 330
        spacing: 8

        Repeater {
            model: notif.items.slice(0, 3)

            delegate: Rectangle {
                required property var modelData

                property bool critical: modelData.urgency === NotificationUrgency.Critical
                property int timeout: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000

                color: theme.c.bg
                border.color: critical ? theme.c.accent : (modelData.urgency === NotificationUrgency.Low ? theme.c.dim : theme.c.border)
                border.width: critical ? 2 : 1
                radius: 2
                implicitWidth: 330
                implicitHeight: cardCol.implicitHeight + 16
                Layout.fillWidth: true

                Timer {
                    interval: timeout
                    running: !critical
                    onTriggered: notif.dismiss(modelData)
                }

                ColumnLayout {
                    id: cardCol

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.topMargin: 8
                    spacing: 2

                    Text {
                        text: (modelData.appName || "SYSTEM").toUpperCase()
                        color: theme.c.dim
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.summary || ""
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs
                        font.bold: true
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: (modelData.body || "") !== ""
                        text: modelData.body || ""
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
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
}
