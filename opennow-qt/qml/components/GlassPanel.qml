import QtQuick
import OpenNOW

Rectangle {
    id: root
    property bool strong: false
    property real panelRadius: 20
    // A gold hairline marks the one panel that currently owns input; every
    // other panel keeps the neutral seam so gold stays meaningful.
    property bool accented: false

    color: strong ? Theme.glassStrong : Theme.glass
    border.color: root.accented ? DesktopTokens.goldEdge : Theme.seam
    border.width: DesktopTokens.hairline
    radius: panelRadius

    // Hairline highlight along the top edge. Reads as a lit bevel on black
    // surfaces without introducing a second colour.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 1
        height: 1
        radius: parent.radius
        color: Qt.rgba(1, 1, 1, Theme.lightMode ? 0.30 : 0.10)
        visible: !Theme.lightMode
    }

    Behavior on border.color { ColorAnimation { duration: Theme.focusDuration } }
}
