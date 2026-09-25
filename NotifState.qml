import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Notification intake: tracks incoming notifications, caps the list.
QtObject {
    id: root

    property var items: [] // newest first, max 6
    property int unread: 0

    function markRead() {
        root.unread = 0;
    }

    function clearAll() {
        var a = root.items.slice();
        root.items = [];
        root.unread = 0;
        for (var i = 0; i < a.length; i++) {
            try {
                a[i].dismiss();
            } catch (e) {}
        }
    }

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
            root.unread = root.unread + 1;
        }
    }
}
