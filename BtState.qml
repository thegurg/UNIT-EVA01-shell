import QtQuick

// Shared open/close state for the bluetooth panel.
QtObject {
    id: root

    property bool open: false // TEST revert

    function toggle() {
        open = !open;
    }
    function close() {
        open = false;
    }
}
