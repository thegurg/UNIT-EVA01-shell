import QtQuick

// Vertical spectrum strip: 24 columns x 7 segments.
Row {
    id: root

    property var theme
    property var levels: []

    spacing: 3

    Repeater {
        model: root.levels.length

        delegate: Column {
            id: colDel

            required property int index

            spacing: 2

            property int lit: root.levels[colDel.index] || 0

            Repeater {
                model: 7

                delegate: Rectangle {
                    required property int index

                    // draw bottom-up: segment row (6 - index) must be < lit
                    width: 8
                    height: 5
                    radius: 1
                    property bool on: (6 - index) < colDel.lit
                    color: on ? ((6 - index) >= 5 ? root.theme.c.accent : root.theme.c.accent2) : "transparent"
                    border.color: on ? "transparent" : root.theme.c.dim
                    border.width: on ? 0 : 1
                }
            }
        }
    }
}
