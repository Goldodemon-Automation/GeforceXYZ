import QtQuick
import OpenNOW

Rectangle {
    id: panel
    // Settings groups are flat: rows already carry the hairlines, so the group
    // itself needs no card, radius or border.
    property bool paperStyle: false
    property int padding: paperStyle ? 0 : 18
    default property alias content: body.data

    // Flat groups breathe through trailing space instead of a container edge.
    implicitHeight: body.implicitHeight + padding * 2 + (paperStyle ? DesktopTokens.px(16) : 0)
    radius: paperStyle ? 0 : DesktopTokens.px(14)
    color: paperStyle ? "transparent" : Theme.glass
    border.width: paperStyle ? 0 : 1
    border.color: Theme.seam

    Column {
        id: body
        x: panel.padding
        y: panel.padding
        width: panel.width - panel.padding * 2
    }
}
