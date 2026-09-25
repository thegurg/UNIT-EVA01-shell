import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Notification intake: tracks incoming notifications, caps the list.
QtObject {
    id: root

    property var items: [] // newest first, max 6

    function dismiss(n) {
        try {
            n.dismiss();
        } catch (e) {}
        var a = root.items.slice();
        var i = a.indexOf(n);
        if (i >= 0)
            a.splice(i, 1);
        root.items = a;
    }

    property NotificationServer server: NotificationServer {
        actionsSupported: true
        bodySupported: true

        onNotification: n => {
            n.tracked = true;
            var a = [n].concat(root.items);
            if (a.length > 6)
                a.length = 6;
            root.items = a;
        }
    }
}
