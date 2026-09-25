import QtQuick

// Clock capsule, pure QML (no process spawn).
Rectangle {
    id: root

    property var theme

    color: theme.c.panel
    border.color: theme.c.border
    border.width: 1
    radius: 2
    implicitHeight: theme.segHeight
    implicitWidth: label.width + 16

    Text {
        id: label

        anchors.centerIn: parent
        text: "--.-- --:--:--"
        verticalAlignment: Text.AlignVCenter
        color: root.theme.c.accent2
        font.family: root.theme.font
        font.pixelSize: root.theme.fs
        font.bold: true
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: label.text = Qt.formatDateTime(new Date(), "dd.MM hh:mm:ss").toUpperCase()
    }
}
