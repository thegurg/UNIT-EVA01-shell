import Quickshell.Io
import QtQuick

// EXPERIMENTAL: live spectrum levels from cava raw stdout.
// Process runs only while `active`; strip hides after 2s without frames.
QtObject {
    id: root

    property int bars: 24
    property int maxLevel: 7
    property var levels: []
    property bool active: false

    Component.onCompleted: reset()

    function reset() {
        var a = [];
        for (var i = 0; i < root.bars; i++)
            a.push(0);
        root.levels = a;
    }

    property Process proc: Process {
        running: root.active
        command: ["cava", "-p", "/home/tg/.config/quickshell/cava-raw.conf"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var parts = String(data).trim().split(";");
                if (parts.length < root.bars)
                    return;
                var a = [];
                for (var i = 0; i < root.bars; i++) {
                    var v = parseInt(parts[i], 10);
                    if (isNaN(v))
                        v = 0;
                    a.push(Math.max(0, Math.min(root.maxLevel, v)));
                }
                root.levels = a;
                root.watchdog.restart();
            }
        }
    }

    property Timer watchdog: Timer {
        interval: 2000
        onTriggered: root.reset()
    }
}
