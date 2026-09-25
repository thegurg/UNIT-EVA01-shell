import QtQuick

// Compact text stats capsule. Click toggles the SysMon dropdown.
Rectangle {
    id: root

    property var theme
    property var sys
    property var mon
    property var panels

    property string batText: root.sys.bat === "AC" ? "AC" : root.sys.bat + "%"

    color: mon.open ? theme.c.accent : theme.c.panel
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
        color: mon.open ? theme.c.bg : root.theme.c.fg
        font.family: root.theme.font
        font.pixelSize: root.theme.fs
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            mon.toggle();
            if (mon.open) {
                panels.cc.close();
                panels.nc.close();
                panels.pstate.close();
                panels.wifi.close();
                panels.bt.close();
            }
        }
    }
}
