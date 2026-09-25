import Quickshell.Services.Mpris
import QtQuick

// MPRIS player capsule. Left click = toggle island, right click = next.
// Hidden when no players are connected.
Rectangle {
    id: root

    property var theme
    property var pstate
    property var panels
    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    visible: player !== null

    color: theme.c.panel
    border.color: theme.c.border
    border.width: 1
    radius: 2
    implicitHeight: theme.segHeight
    implicitWidth: label.width + 16

    Text {
        id: label

        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 280)
        text: {
            if (root.player === null)
                return "";
            var icon = root.player.playbackState === MprisPlaybackState.Playing ? "⏸ " : "▶ ";
            var t = root.player.trackTitle || "---";
            var a = root.player.trackArtist || "";
            return "♪ " + icon + t + (a !== "" ? " — " + a : "");
        }
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        color: root.theme.c.accent2
        font.family: root.theme.font
        font.pixelSize: root.theme.fs
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (root.player === null)
                return;
            if (mouse.button === Qt.RightButton && root.player.canGoNext) {
                root.player.next();
                return;
            }
            pstate.toggle();
            if (pstate.open) {
                panels.cc.close();
                panels.nc.close();
                panels.mon.close();
                panels.wifi.close();
                panels.bt.close();
            }
        }
    }
}
