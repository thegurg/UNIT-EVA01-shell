import Quickshell
import Quickshell.Io
import QtQuick

// System stats polled from sysinfo.sh (one line: CPU=.. MEM=.. TEMP=.. BAT=.. VOL=..)
QtObject {
    id: root

    property string scriptPath: ""
    property int cpu: 0
    property int mem: 0
    property int temp: 0
    property string bat: "--"
    property int vol: 0
    property int bri: 0
    property string uptime: "--"
    property string load: "0,0,0"
    property int disk: 0

    function refresh() {
        if (scriptPath === "" || proc.running)
            return;
        proc.command = ["bash", scriptPath];
        proc.running = true;
    }

    property Process proc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(/\s+/);
                for (var i = 0; i < parts.length; i++) {
                    var kv = parts[i].split("=");
                    if (kv.length !== 2)
                        continue;
                    if (kv[0] === "CPU")
                        root.cpu = parseInt(kv[1], 10) || 0;
                    else if (kv[0] === "MEM")
                        root.mem = parseInt(kv[1], 10) || 0;
                    else if (kv[0] === "TEMP")
                        root.temp = parseInt(kv[1], 10) || 0;
                    else if (kv[0] === "BAT")
                        root.bat = kv[1];
                    else if (kv[0] === "VOL")
                        root.vol = parseInt(kv[1], 10) || 0;
                    else if (kv[0] === "BRI")
                        root.bri = parseInt(kv[1], 10) || 0;
                    else if (kv[0] === "UPTIME")
                        root.uptime = kv[1];
                    else if (kv[0] === "LOAD")
                        root.load = kv[1];
                    else if (kv[0] === "DISK")
                        root.disk = parseInt(kv[1], 10) || 0;
                }
            }
        }
    }

    property Timer pollTimer: Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
