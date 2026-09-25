import QtQuick

// Mini segmented health-bar (CyberArch style).
Row {
    id: root

    property var theme
    property int value: 0
    property color fill: "#FFFFFF"
    property int segs: 8

    spacing: 2

    property int lit: Math.max(0, Math.min(segs, Math.round((value / 100) * segs)))

    Repeater {
        model: root.segs

        delegate: Rectangle {
            required property int index

            width: 6
            height: 12
            radius: 1
            color: index < root.lit ? root.fill : "transparent"
            border.color: index < root.lit ? "transparent" : root.theme.c.dim
            border.width: index < root.lit ? 0 : 1
        }
    }
}
