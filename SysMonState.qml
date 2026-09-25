import QtQuick

// Shared open/close state for the SysMon dropdown.
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
