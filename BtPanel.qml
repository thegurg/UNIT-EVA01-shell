import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Bluetooth picker (bluetui-like, in our UI): power, scan, pair/connect/remove.
PanelWindow {
    id: bt

    required property var modelData
    property var theme
    property var state
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

    visible: state.open
    implicitWidth: 340

    property bool powered: false
    property bool scanning: false
    property var devs: [] // {mac, name, paired, connected}
    property string msg: ""

    function runBuffered(actor, cmd) {
        if (actor.running) {
            var t = Qt.createQmlObject("import QtQuick; Timer { interval: 200; repeat: false }", bt);
            t.triggered.connect(() => {
                runBuffered(actor, cmd);
                t.destroy();
            });
            t.start();
        } else {
            actor.command = cmd;
            actor.running = true;
        }
    }

    function refresh() {
        if (!powerProc.running)
            powerProc.running = true;
        if (!listProc.running)
            listProc.running = true;
    }

    function doConnect(mac, paired) {
        if (paired) {
            runBuffered(btActor, ["bluetoothctl", "connect", mac]);
        } else {
            runBuffered(btActor, ["bash", "-c", "printf 'agent NoInputNoOutput\\ndefault-agent\\npair " + mac + "\\ntrust " + mac + "\\nconnect " + mac + "\\nquit\\n' | bluetoothctl >/dev/null 2>&1"]);
        }
        msg = "LINK " + mac + " ...";
        later();
    }

    function later() {
        var t = Qt.createQmlObject("import QtQuick; Timer { interval: 4000; repeat: false }", bt);
        t.triggered.connect(() => {
            refresh();
            msg = "";
            t.destroy();
        });
        t.start();
    }

    onVisibleChanged: {
        if (visible)
            refresh();
    }

    property Process powerProc: Process {
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: bt.powered = (text.trim() === "yes")
        }
    }

    property Process listProc: Process {
        command: ["bash", "-c", "PAIRED=$(bluetoothctl paired-devices 2>/dev/null | awk '{print $2}'); CONN=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); bluetoothctl devices 2>/dev/null | while read -r _ mac rest; do p=0; c=0; echo \"$PAIRED\" | grep -q \"$mac\" && p=1; echo \"$CONN\" | grep -q \"$mac\" && c=1; echo \"$mac|$p|$c|$rest\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                var a = [];
                for (var i = 0; i < lines.length; i++) {
                    var m = lines[i].match(/^(\S+)\|([01])\|([01])\|(.*)$/);
                    if (!m)
                        continue;
                    a.push({ "mac": m[1], "paired": m[2] === "1", "connected": m[3] === "1", "name": m[4] || m[1] });
                }
                a.sort((x, y) => ((y.connected - x.connected) || (y.paired - x.paired)));
                if (a.length > 8)
                    a.length = 8;
                bt.devs = a;
            }
        }
    }

    property Process btActor: Process {}
    property Process scanActor: Process {}

    property Timer pollTimer: Timer {
        interval: 5000
        repeat: true
        running: bt.visible
        triggeredOnStart: true
        onTriggered: bt.refresh()
    }

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
                    text: "歯車 BT"
                    color: theme.c.accent
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: scanning ? theme.c.accent2 : "transparent"
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitWidth: 60
                    implicitHeight: 22

                    Text {
                        anchors.centerIn: parent
                        text: scanning ? "SCAN.." : "SCAN"
                        color: scanning ? theme.c.bg : theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            scanning = true;
                            runBuffered(scanActor, ["bash", "-c", "bluetoothctl scan on >/dev/null 2>&1 & sleep 12; bluetoothctl scan off >/dev/null 2>&1"]);
                            var t = Qt.createQmlObject("import QtQuick; Timer { interval: 13000; repeat: false }", bt);
                            t.triggered.connect(() => {
                                scanning = false;
                                refresh();
                                t.destroy();
                            });
                            t.start();
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
                        onClicked: state.close()
                    }
                }
            }

            Rectangle {
                color: powered ? theme.c.accent2 : theme.c.panel
                border.color: theme.c.border
                border.width: 1
                radius: 2
                implicitHeight: 28
                Layout.fillWidth: true

                Text {
                    anchors.centerIn: parent
                    text: "POWER " + (powered ? "ON" : "OFF")
                    color: powered ? theme.c.bg : theme.c.fg
                    font.family: theme.font
                    font.pixelSize: theme.fs - 1
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        powered = !powered;
                        runBuffered(btActor, ["bluetoothctl", "power", powered ? "on" : "off"]);
                    }
                }
            }

            Text {
                visible: !powered
                text: "POWER OFF"
                color: theme.c.dim
                font.family: theme.font
                font.pixelSize: theme.fs - 1
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                visible: powered && devs.length === 0
                text: "NO DEVICES — SCAN"
                color: theme.c.dim
                font.family: theme.font
                font.pixelSize: theme.fs - 1
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Repeater {
                model: powered ? devs : []

                delegate: Rectangle {
                    required property var modelData

                    color: modelData.connected ? theme.c.accent2 : theme.c.panel
                    border.color: modelData.connected ? "transparent" : theme.c.dim
                    border.width: modelData.connected ? 0 : 1
                    radius: 2
                    implicitHeight: 28
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: (modelData.connected ? "▶ " : (modelData.paired ? "● " : "○ ")) + modelData.name
                            color: modelData.connected ? theme.c.bg : theme.c.fg
                            font.family: theme.font
                            font.pixelSize: theme.fs - 1
                            font.bold: modelData.connected
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "✕"
                            color: modelData.connected ? theme.c.bg : theme.c.dim
                            font.family: theme.font
                            font.pixelSize: theme.fs - 1
                            font.bold: true

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    runBuffered(btActor, ["bash", "-c", "bluetoothctl disconnect " + modelData.mac + " >/dev/null 2>&1; bluetoothctl remove " + modelData.mac]);
                                    later();
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.connected)
                                runBuffered(btActor, ["bluetoothctl", "disconnect", modelData.mac]);
                            else
                                doConnect(modelData.mac, modelData.paired);
                            later();
                        }
                    }
                }
            }

            Text {
                visible: msg !== ""
                text: msg
                color: theme.c.accent2
                font.family: theme.font
                font.pixelSize: theme.fs - 2
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }
}
