import Quickshell
import Quickshell.Io
import QtQuick

// Default config entry: `quickshell` / `qs` runs this file.
ShellRoot {
    id: root

    property string cfgDir: Qt.resolvedUrl(".").toString().replace("file://", "")

    Theme {
        id: themeData
    }

    Niri {
        id: niriData
    }

    Sys {
        id: sysData
        scriptPath: "/home/tg/.config/quickshell/sysinfo.sh"
    }

    CCState {
        id: ccData
    }

    NotifState {
        id: notifData
    }

    OSDData {
        id: osdState
    }

    IpcHandler {
        target: "osd"

        function poke(kind: string): void {
            osdState.poke(kind);
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            screen: modelData
            theme: themeData
            niri: niriData
            sys: sysData
            cc: ccData
        }
    }

    Variants {
        model: Quickshell.screens

        ControlCenter {
            screen: modelData
            theme: themeData
            sys: sysData
            state: ccData
        }
    }

    Variants {
        model: Quickshell.screens

        Notifications {
            screen: modelData
            theme: themeData
            notif: notifData
            cc: ccData
        }
    }

    Variants {
        model: Quickshell.screens

        OSD {
            screen: modelData
            theme: themeData
            osdData: osdState
        }
    }
}
