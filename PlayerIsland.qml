import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

// Floating player island, top-center. Cover + controls + progress + visualizer.
PanelWindow {
    id: island

    required property var modelData
    property var theme
    property var pstate
    property var cava

    screen: modelData

    anchors {
        left: true
        right: true
        top: true
    }
    margins {
        top: theme.barHeight + 8
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    visible: pstate.open && player !== null

    function fmt(s) {
        s = Math.max(0, Math.floor(s || 0));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    property real frac: (player !== null && (player.length || 0) > 0) ? Math.min(1, (player.position || 0) / player.length) : 0

    // keep position ticking while playing
    property Timer posTimer: Timer {
        interval: 1000
        repeat: true
        running: island.visible && island.player !== null && island.player.playbackState === MprisPlaybackState.Playing
        onTriggered: island.player.positionChanged()
    }

    onVisibleChanged: {
        if (visible && player !== null)
            player.positionChanged();
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 470
        height: mainCol.implicitHeight + 32
        color: theme.c.bg
        border.color: theme.c.border
        border.width: 2
        radius: 2

        ColumnLayout {
            id: mainCol

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // cover with glyph fallback
                Rectangle {
                    color: theme.c.panel
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitWidth: 84
                    implicitHeight: 84
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: theme.c.dim
                        font.pixelSize: 32
                    }

                    Image {
                        anchors.fill: parent
                        source: island.player !== null ? (island.player.trackArtUrl || "") : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: island.player !== null ? (island.player.trackTitle || "---") : ""
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: island.player !== null ? (island.player.trackArtist || island.player.identity || "") : ""
                        color: theme.c.dim
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: 6

                        Repeater {
                            model: [
                                { "t": "⏮", "a": "prev" },
                                { "t": island.player !== null && island.player.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶", "a": "toggle" },
                                { "t": "⏭", "a": "next" }
                            ]

                            delegate: Rectangle {
                                required property var modelData

                                color: theme.c.panel
                                border.color: theme.c.border
                                border.width: 1
                                radius: 2
                                implicitWidth: 40
                                implicitHeight: 26

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.t
                                    color: theme.c.fg
                                    font.family: theme.font
                                    font.pixelSize: theme.fs
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (island.player === null)
                                            return;
                                        if (modelData.a === "prev" && island.player.canGoPrevious)
                                            island.player.previous();
                                        else if (modelData.a === "next" && island.player.canGoNext)
                                            island.player.next();
                                        else if (modelData.a === "toggle" && island.player.canTogglePlaying)
                                            island.player.togglePlaying();
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    color: "transparent"
                    border.color: theme.c.dim
                    border.width: 1
                    radius: 2
                    implicitWidth: 26
                    implicitHeight: 22
                    Layout.alignment: Qt.AlignTop

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
                        onClicked: pstate.close()
                    }
                }
            }

            // progress times (bar itself is full-width at the card bottom)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: fmt(island.player !== null ? island.player.position : 0)
                        color: theme.c.dim
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: fmt(island.player !== null ? island.player.length : 0)
                        color: theme.c.dim
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                    }
                }
            }

            // experimental visualizer strip
            VizBar {
                theme: island.theme
                levels: cava.levels
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // full-width progress bar at the card bottom (viz reference)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            anchors.bottomMargin: 2
            height: 7
            color: theme.c.panel
            radius: 2

            Rectangle {
                width: parent.width * frac
                height: parent.height
                color: theme.c.accent
                radius: 2
            }
        }

        Grain {
            anchors.fill: parent
        }
    }
}
