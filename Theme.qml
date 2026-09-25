import QtQuick

// Central design tokens. Default theme: EVA-01.
// Click the EVA label on the bar to cycle: next()
QtObject {
    id: root

    property var order: ["EVA-01", "LAIN", "NERV-01", "ACID-VOID", "GRUNGE-PINK", "CONCRETE"]
    property string current: "EVA-01"

    property var themes: ({
        "EVA-01": {
            "bg": "#101419",
            "panel": "#1E222A",
            "fg": "#C8CCD4",
            "dim": "#594384",
            "accent": "#CC02F5",
            "accent2": "#67C976",
            "border": "#67C976",
            "label": "EVA"
        },
        "LAIN": {
            "bg": "#070B16",
            "panel": "#0D1424",
            "fg": "#C7D5EE",
            "dim": "#3E4C6D",
            "accent": "#4D7CFF",
            "accent2": "#57E6FF",
            "border": "#4D7CFF",
            "label": "LAIN"
        },
        "NERV-01": {
            "bg": "#0A0A0A",
            "panel": "#161616",
            "fg": "#EDEDED",
            "dim": "#6B6B6B",
            "accent": "#FF1A1A",
            "accent2": "#2A6FFF",
            "border": "#FF1A1A",
            "label": "NERV"
        },
        "ACID-VOID": {
            "bg": "#0A0A0A",
            "panel": "#161616",
            "fg": "#EDEDED",
            "dim": "#6B6B6B",
            "accent": "#B400FF",
            "accent2": "#00F0FF",
            "border": "#B400FF",
            "label": "VOID"
        },
        "GRUNGE-PINK": {
            "bg": "#0C0C0C",
            "panel": "#1A1A1A",
            "fg": "#EDEDED",
            "dim": "#6B6B6B",
            "accent": "#FF2A6D",
            "accent2": "#C6FF00",
            "border": "#FF2A6D",
            "label": "GRUNGE"
        },
        "CONCRETE": {
            "bg": "#D6D6D6",
            "panel": "#C9C9C9",
            "fg": "#111111",
            "dim": "#5C5C5C",
            "accent": "#FF4D00",
            "accent2": "#111111",
            "border": "#111111",
            "label": "CONCRETE"
        }
    })

    property var c: themes[current]
    property string font: "JetBrainsMono Nerd Font Mono"
    property int fs: 13
    property int barHeight: 38
    property int segHeight: 26

    function next() {
        var i = (order.indexOf(current) + 1) % order.length;
        current = order[i];
    }
}
