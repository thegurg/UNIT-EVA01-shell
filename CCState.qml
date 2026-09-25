import QtQuick

// Shared open/close state for the Control Center dropdown.
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
