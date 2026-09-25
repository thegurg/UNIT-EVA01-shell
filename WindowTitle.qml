import QtQuick

// Center capsule: focused window as "APP :: title", elided.
Rectangle {
    id: root

    property var theme
    property var niri

    color: theme.c.panel
    border.color: theme.c.border
    border.width: 1
    radius: 2
    implicitHeight: theme.segHeight

    Text {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        text: "◢ " + (root.niri.focusedApp !== "" ? root.niri.focusedApp.toUpperCase() + " :: " : "") + root.niri.focusedTitle
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        color: root.theme.c.fg
        font.family: root.theme.font
        font.pixelSize: root.theme.fs
    }
}
