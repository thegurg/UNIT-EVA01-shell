import Quickshell
import Quickshell.Io
import QtQuick

// Niri state via `niri msg -j` polling (v1, no plugin dependency).
QtObject {
    id: root

    property var workspaces: []
    property string focusedTitle: "---"
    property string focusedApp: ""

    function refresh() {
        if (!wsProc.running)
            wsProc.running = true;
        if (!winProc.running)
            winProc.running = true;
    }

    function focusWorkspace(ref) {
        actor.command = ["niri", "msg", "action", "focus-workspace", String(ref)];
        actor.running = true;
    }

    property Process wsProc: Process {
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var ws = JSON.parse(text);
                    ws.sort(function (a, b) { return a.idx - b.idx; });
                    root.workspaces = ws;
                } catch (e) {}
            }
        }
    }

    property Process winProc: Process {
        command: ["niri", "msg", "-j", "windows"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var wins = JSON.parse(text);
                    var f = null;
                    for (var i = 0; i < wins.length; i++) {
                        if (wins[i].is_focused) {
                            f = wins[i];
                            break;
                        }
                    }
                    if (f) {
                        root.focusedTitle = f.title || "---";
                        root.focusedApp = f.app_id || "";
                    } else {
                        root.focusedTitle = "---";
                        root.focusedApp = "";
                    }
                } catch (e) {}
            }
        }
    }

    property Process actor: Process {}

    property Timer pollTimer: Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
