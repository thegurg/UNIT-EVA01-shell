import QtQuick

// Film grain overlay. Tile over panel backgrounds, keep opacity subtle.
Image {
    id: root

    property real strength: 0.07

    source: "/home/tg/.config/quickshell/grain.png"
    fillMode: Image.Tile
    opacity: strength
}
