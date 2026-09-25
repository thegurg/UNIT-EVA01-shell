import QtQuick

// Workspace blocks in an Exodia-style capsule.
// Filled = focused, bordered = has windows, dim = empty. Click focuses.
Rectangle {
    id: root

    property var theme
    property var niri

    color: theme.c.panel
    border.color: theme.c.border
    border.width: 1
    radius: 2
    implicitHeight: theme.segHeight
    implicitWidth: inner.width + 16

    Row {
        id: inner

        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        spacing: 6

        Repeater {
            model: root.niri.workspaces
            delegate: Rectangle {
                required property var modelData

                width: 30
                height: 18
                color: modelData.is_focused ? root.theme.c.accent : "transparent"
                border.width: modelData.is_focused ? 0 : 1
                border.color: modelData.is_focused ? "transparent" : (modelData.active_window_id ? root.theme.c.fg : root.theme.c.dim)

                Text {
                    anchors.centerIn: parent
                    text: String(modelData.idx).padStart(2, "0")
                    font.family: root.theme.font
                    font.pixelSize: root.theme.fs - 1
                    font.bold: modelData.is_focused
                    color: modelData.is_focused ? root.theme.c.bg : (modelData.active_window_id ? root.theme.c.fg : root.theme.c.dim)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.niri.focusWorkspace(modelData.idx)
                }
            }
        }
    }
}
