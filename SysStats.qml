import QtQuick

// Stats capsule.
Rectangle {
    id: root

    property var theme
    property var sys

    property string batText: root.sys.bat === "AC" ? "AC" : root.sys.bat + "%"

    color: theme.c.panel
    border.color: theme.c.border
    border.width: 1
    radius: 2
    implicitHeight: theme.segHeight
    implicitWidth: label.width + 16

    Text {
        id: label

        anchors.centerIn: parent
        text: "CPU " + root.sys.cpu + "% ▮ MEM " + root.sys.mem + "% ▮ " + root.sys.temp + "°C ▮ BAT " + root.batText + " ▮ VOL " + root.sys.vol + "%"
        verticalAlignment: Text.AlignVCenter
        color: root.theme.c.fg
        font.family: root.theme.font
        font.pixelSize: root.theme.fs
    }
}
