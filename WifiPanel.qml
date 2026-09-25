import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

// Wifi picker (nmtui-like, in our UI): scan list, connect + password, disconnect.
PanelWindow {
    id: wifi

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
    focusable: true

    visible: state.open
    implicitWidth: 340

    property bool radioOn: true
    property string iface: ""
    property string activeSsid: ""
    property var nets: []
    property string selected: ""
    property string msg: ""

    function runBuffered(actor, cmd) {
        if (actor.running) {
            var t = Qt.createQmlObject("import QtQuick; Timer { interval: 200; repeat: false }", wifi);
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

    function refresh(rescan) {
        if (!radioProc.running)
            radioProc.running = true;
        if (!ifaceProc.running && iface === "")
            ifaceProc.running = true;
        if (!listProc.running) {
            listProc.command = ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "device", "wifi", "list", "--rescan", rescan ? "yes" : "no"];
            listProc.running = true;
        }
    }

    function connect(ssid, pass) {
        var cmd = ["nmcli", "device", "wifi", "connect", ssid];
        if (pass !== "")
            cmd.push("password", pass);
        runBuffered(netActor, cmd);
        msg = "CONNECTING " + ssid + " ...";
        passField.text = "";
        var t = Qt.createQmlObject("import QtQuick; Timer { interval: 5000; repeat: false }", wifi);
        t.triggered.connect(() => {
            refresh(false);
            msg = "";
            t.destroy();
        });
        t.start();
    }

    onVisibleChanged: {
        if (visible)
            refresh(false);
    }

    property Process radioProc: Process {
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: wifi.radioOn = (text.trim() === "enabled")
        }
    }

    property Process ifaceProc: Process {
        command: ["bash", "-c", "nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2==\"wifi\"{print $1; exit}'"]
        stdout: StdioCollector {
            onStreamFinished: wifi.iface = text.trim()
        }
    }

    property Process listProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                var a = [];
                var act = "";
                for (var i = 0; i < lines.length; i++) {
                    var m = lines[i].match(/^([^:]*):([0-9]+):([^:]*):(.*)$/);
                    if (!m)
                        continue;
                    var ssid = m[4].replace(/\\:/g, ":").replace(/\\\\/g, "\\");
                    if (ssid === "")
                        continue;
                    var inuse = m[1] === "*";
                    if (inuse)
                        act = ssid;
                    a.push({ "ssid": ssid, "signal": parseInt(m[2], 10) || 0, "secure": (m[3] !== "" && m[3] !== "--"), "inuse": inuse });
                }
                a.sort((x, y) => y.signal - x.signal);
                if (a.length > 8)
                    a.length = 8;
                wifi.nets = a;
                wifi.activeSsid = act;
            }
        }
    }

    property Process netActor: Process {}

    property Timer pollTimer: Timer {
        interval: 10000
        repeat: true
        running: wifi.visible
        triggeredOnStart: true
        onTriggered: wifi.refresh(false)
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
                    text: "無線 WIFI"
                    color: theme.c.accent
                    font.family: theme.font
                    font.pixelSize: theme.fs
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: "transparent"
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitWidth: 70
                    implicitHeight: 22

                    Text {
                        anchors.centerIn: parent
                        text: "RESCAN"
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: refresh(true)
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    color: radioOn ? theme.c.accent2 : theme.c.panel
                    border.color: theme.c.border
                    border.width: 1
                    radius: 2
                    implicitHeight: 28
                    Layout.fillWidth: true

                    Text {
                        anchors.centerIn: parent
                        text: "RADIO " + (radioOn ? "ON" : "OFF")
                        color: radioOn ? theme.c.bg : theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            radioOn = !radioOn;
                            runBuffered(netActor, ["nmcli", "radio", "wifi", radioOn ? "on" : "off"]);
                        }
                    }
                }

                Rectangle {
                    visible: activeSsid !== ""
                    color: "transparent"
                    border.color: theme.c.accent
                    border.width: 1
                    radius: 2
                    implicitHeight: 28
                    Layout.fillWidth: true

                    Text {
                        anchors.centerIn: parent
                        text: "DISC " + activeSsid
                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 2
                        font.bold: true
                        width: Math.min(implicitWidth, 150)
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (iface !== "")
                                runBuffered(netActor, ["nmcli", "device", "disconnect", iface]);
                        }
                    }
                }
            }

            Text {
                visible: !radioOn
                text: "RADIO OFF"
                color: theme.c.dim
                font.family: theme.font
                font.pixelSize: theme.fs - 1
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Repeater {
                model: radioOn ? nets : []

                delegate: Rectangle {
                    id: netRow

                    required property var modelData

                    color: modelData.inuse ? theme.c.accent : (selected === modelData.ssid ? theme.c.panel : "transparent")
                    border.color: modelData.inuse ? "transparent" : theme.c.dim
                    border.width: modelData.inuse ? 0 : 1
                    radius: 2
                    implicitHeight: 28
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: (modelData.inuse ? "▶ " : "") + modelData.ssid
                            color: modelData.inuse ? theme.c.bg : theme.c.fg
                            font.family: theme.font
                            font.pixelSize: theme.fs - 1
                            font.bold: modelData.inuse
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: (modelData.secure ? "" : "OPEN ") + modelData.signal + "%"
                            color: modelData.inuse ? theme.c.bg : theme.c.dim
                            font.family: theme.font
                            font.pixelSize: theme.fs - 2
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.inuse)
                                return;
                            if (!modelData.secure) {
                                connect(modelData.ssid, "");
                            } else {
                                selected = (selected === modelData.ssid) ? "" : modelData.ssid;
                            }
                        }
                    }
                }
            }

            // password row for secured networks
            Rectangle {
                visible: selected !== ""
                color: theme.c.panel
                border.color: theme.c.accent
                border.width: 1
                radius: 2
                implicitHeight: 30
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    TextInput {
                        id: passField

                        color: theme.c.fg
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        Layout.fillWidth: true
                        activeFocusOnPress: true
                        onAccepted: {
                            connect(selected, text);
                            selected = "";
                        }
                    }

                    Text {
                        text: "GO →"
                        color: theme.c.accent2
                        font.family: theme.font
                        font.pixelSize: theme.fs - 1
                        font.bold: true

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                connect(selected, passField.text);
                                selected = "";
                            }
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
