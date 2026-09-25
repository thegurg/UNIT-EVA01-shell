import Quickshell
import Quickshell.Io
import QtQuick

// Shared OSD state: instant poke() via IPC + silent polling fallback.
QtObject {
    id: root

    property string kind: "vol" // "vol" | "bri"
    property int vol: 0
    property bool muted: false
    property int bri: 0
    property bool shown: false
    property bool loudPending: false

    function poke(k) {
        kind = k;
        loudPending = true;
        fetch();
        hideTimer.restart();
    }

    function fetch() {
        if (fetchProc.running)
            return;
        fetchProc.command = ["bash", "/home/tg/.config/quickshell/osdfetch.sh"];
        fetchProc.running = true;
    }

    property Process fetchProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                var loud = root.loudPending;
                root.loudPending = false;
                var changed = false;
                var parts = text.trim().split(/\s+/);
                for (var i = 0; i < parts.length; i++) {
                    var kv = parts[i].split("=");
                    if (kv.length !== 2)
                        continue;
                    if (kv[0] === "VOL") {
                        var v = parseInt(kv[1], 10) || 0;
                        if (v !== root.vol)
                            changed = true;
                        root.vol = v;
                    } else if (kv[0] === "MUTED") {
                        var m = kv[1] === "1";
                        if (m !== root.muted)
                            changed = true;
                        root.muted = m;
                    } else if (kv[0] === "BRI") {
                        var b = parseInt(kv[1], 10) || 0;
                        if (b !== root.bri)
                            changed = true;
                        root.bri = b;
                    }
                }
                if (loud || changed) {
                    root.shown = true;
                    hideTimer.restart();
                }
            }
        }
    }

    property Timer hideTimer: Timer {
        interval: 1400
        onTriggered: root.shown = false
    }

    // silent fallback: catches changes from CC sliders etc.
    property Timer pollTimer: Timer {
        interval: 800
        repeat: true
        running: true
        onTriggered: root.fetch()
    }
}
