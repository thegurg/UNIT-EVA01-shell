import Quickshell
import QtQuick
import QtQuick.Layouts

// Bottom-center OSD with segmented health-bars. Overlay, reserves no space.
PanelWindow {
    id: osd

    required property var modelData
    property var theme
    property var osdData

    screen: modelData

    anchors {
        left: true
        right: true
        bottom: true
    }
    margins {
        bottom: 70
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    visible: osdData.shown

    property int segCount: 20
    property int filled: Math.round(((osdData.kind === "vol" ? osdData.vol : osdData.bri) / 100) * segCount)
    property color barColor: osdData.kind === "vol" ? (osdData.muted ? theme.c.dim : theme.c.accent) : theme.c.accent2
    property string title: osdData.kind === "vol" ? (osdData.muted ? "MUTED" : "VOL " + osdData.vol + "%") : "BRI " + osdData.bri + "%"

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: boxContent.implicitWidth + 32
        height: boxContent.implicitHeight + 20
        color: theme.c.bg
        border.color: theme.c.border
        border.width: 2
        radius: 2

        ColumnLayout {
            id: boxContent

            anchors.centerIn: parent
            spacing: 8

            Text {
                text: title
                color: theme.c.fg
                font.family: theme.font
                font.pixelSize: theme.fs
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Row {
                spacing: 3
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: segCount

                    delegate: Rectangle {
                        required property int index

                        width: 10
                        height: 20
                        color: index < filled ? barColor : theme.c.panel
                        border.color: index < filled ? "transparent" : theme.c.dim
                        border.width: index < filled ? 0 : 1
                        radius: 1
                    }
                }
            }
        }
    }
}
