import QtQuick

// Shared open/close state for the notification center.
QtObject {
    id: root

    property bool open: false

    function toggle() {
        open = !open;
    }
    function close() {
        open = false;
    }
}
