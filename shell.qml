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

    SysMonState {
        id: monData
    }

    NotifState {
        id: notifData
    }

    NotifCenterState {
        id: ncData
    }

    PlayerState {
        id: pstateData
    }

    WifiState {
        id: wifiData
    }

    BtState {
        id: btData
    }

    Cava {
        id: cavaData
        active: pstateData.open
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

    IpcHandler {
        target: "sysmon"

        function close(): void {
            monData.close();
        }
    }

    IpcHandler {
        target: "ui"

        function closeAll(): void {
            ccData.close();
            monData.close();
            ncData.close();
            pstateData.close();
            wifiData.close();
            btData.close();
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
            mon: monData
            notif: notifData
            nc: ncData
            pstate: pstateData
            wifi: wifiData
            bt: btData
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
            nc: ncData
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

    Variants {
        model: Quickshell.screens

        SysMon {
            screen: modelData
            theme: themeData
            sys: sysData
            state: monData
            cc: ccData
        }
    }

    Variants {
        model: Quickshell.screens

        NotifCenter {
            screen: modelData
            theme: themeData
            notif: notifData
            nc: ncData
            cc: ccData
        }
    }

    Variants {
        model: Quickshell.screens

        PlayerIsland {
            screen: modelData
            theme: themeData
            pstate: pstateData
            cava: cavaData
        }
    }

    Variants {
        model: Quickshell.screens

        WifiPanel {
            screen: modelData
            theme: themeData
            state: wifiData
            cc: ccData
        }
    }

    Variants {
        model: Quickshell.screens

        BtPanel {
            screen: modelData
            theme: themeData
            state: btData
            cc: ccData
        }
    }
}
