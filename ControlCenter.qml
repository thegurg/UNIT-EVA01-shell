import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Dropdown control center: toggles, sliders, power.
PanelWindow {
    id: cc

    required property var modelData
    property var theme
    property var sys
    property var state

    screen: modelData

    anchors {
        top: true
        right: true
    }
    margins {
        top: theme.barHeight + 8
        right: 10
    }
    implicitWidth: 300
    implicitHeight: col.implicitHeight + 20
    color: "transparent"

    visible: state.open

    property bool wifiOn: false
    property bool btOn: false

    function refresh() {
        if (!wifiProc.running)
            wifiProc.running = true;
        if (!btProc.running)
            btProc.running = true;
    }

    onVisibleChanged: {
        if (visible)
            refresh();
    }

    property Process wifiProc: Process {
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: cc.wifiOn = (text.trim() === "enabled")
        }
    }

    property Process btProc: Process {
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: cc.btOn = (text.trim() === "yes")
        }
    }

    property Process wifiActor: Process {}
    property Process btActor: Process {}
    property Process volActor: Process {}
    property Process briActor: Process {}
    property Process powerActor: Process {}

    // Buffered run: never drops a command when the actor is busy,
    // retries until the previous command finishes.
    function runBuffered(actor, cmd) {
        if (actor.running) {
            var t = Qt.createQmlObject("import QtQuick; Timer { interval: 150; repeat: false }", cc);
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

    property Timer pollTimer: Timer {
        interval: 5000
        repeat: true
        running: cc.visible
        triggeredOnStart: true
        onTriggered: cc.refresh()
    }

    Rectangle {
        anchors.fill: parent
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
            spacing: 10

            // header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "制御 CONTROL"
                    color: theme.c.accent
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: "transparent"
                    border.color: theme.c.dim
                    border.width: 1
                    radius: 2
                    implicitWidth: 34
                    implicitHeight: 26

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

            // toggles
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // wifi toggle
                Rectangle {
                    color: wifiOn ? theme.c.accent2 : theme.c.panel
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitHeight: 30
                    Layout.fillWidth: true

                    Text {
                        anchors.centerIn: parent
                        text: "WIFI " + (wifiOn ? "ON" : "OFF")
                        color: wifiOn ? theme.c.bg : theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiOn = !wifiOn;
                            runBuffered(wifiActor, ["nmcli", "radio", "wifi", wifiOn ? "on" : "off"]);
                            refresh();
                        }
                    }
                }

                // bluetooth toggle
                Rectangle {
                    color: btOn ? theme.c.accent2 : theme.c.panel
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitHeight: 30
                    Layout.fillWidth: true

                    Text {
                        anchors.centerIn: parent
                        text: "BT " + (btOn ? "ON" : "OFF")
                        color: btOn ? theme.c.bg : theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            btOn = !btOn;
                            runBuffered(btActor, ["bluetoothctl", "power", btOn ? "on" : "off"]);
                            refresh();
                        }
                    }
                }
            }

            // volume slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "VOL " + volSlider.value.toFixed(0) + "%"
                    color: theme.c.fg
                    font.family: theme.font
                    font.pixelSize: theme.fs - 1
                }

                Slider {
                    id: volSlider

                    from: 0
                    to: 100
                    stepSize: 1
                    Layout.fillWidth: true

                    Binding {
                        target: volSlider
                        property: "value"
                        value: sys.vol
                        when: !volSlider.pressed
                    }

                    onPressedChanged: {
                        if (!pressed)
                            runBuffered(volActor, ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(value) + "%"]);
                    }

                    background: Rectangle {
                        implicitHeight: 4
                        color: theme.c.panel
                        border.color: theme.c.border
                        border.width: 1
                        radius: 2

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            color: theme.c.accent
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.visualPosition * (volSlider.width - width)
                        y: (volSlider.height - height) / 2
                        implicitWidth: 12
                        implicitHeight: 18
                        color: theme.c.fg
                        border.color: theme.c.border
                        border.width: 1
                        radius: 2
                    }
                }
            }

            // brightness slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "BRI " + briSlider.value.toFixed(0) + "%"
                    color: theme.c.fg
                    font.family: theme.font
                    font.pixelSize: theme.fs - 1
                }

                Slider {
                    id: briSlider

                    from: 5
                    to: 100
                    stepSize: 1
                    Layout.fillWidth: true

                    Binding {
                        target: briSlider
                        property: "value"
                        value: sys.bri
                        when: !briSlider.pressed
                    }

                    onPressedChanged: {
                        if (!pressed)
                            runBuffered(briActor, ["brightnessctl", "set", Math.round(value) + "%"]);
                    }

                    background: Rectangle {
                        implicitHeight: 4
                        color: theme.c.panel
                        border.color: theme.c.border
                        border.width: 1
                        radius: 2

                        Rectangle {
                            width: briSlider.visualPosition * parent.width
                            height: parent.height
                            color: theme.c.accent2
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: briSlider.visualPosition * (briSlider.width - width)
                        y: (briSlider.height - height) / 2
                        implicitWidth: 12
                        implicitHeight: 18
                        color: theme.c.fg
                        border.color: theme.c.border
                        border.width: 1
                        radius: 2
                    }
                }
            }

            // power row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { "label": "LOCK", "cmd": ["hyprlock"] },
                        { "label": "REBOOT", "cmd": ["systemctl", "reboot"] },
                        { "label": "OFF", "cmd": ["systemctl", "poweroff"] }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        color: theme.c.panel
                        border.color: theme.c.accent
                        border.width: 1
                        radius: 2
                        implicitHeight: 30
                        Layout.fillWidth: true

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: theme.c.fg
                            font.family: theme.font
                            font.pixelSize: theme.fs - 1
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: runBuffered(powerActor, modelData.cmd)
                        }
                    }
                }
            }
        }

        Grain {
            anchors.fill: parent
        }
    }
}
