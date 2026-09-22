import QtQuick
import QtQuick.Effects
import OpenNOW

Item {
    id: root
    property bool focused: false
    property real frameRadius: 20

    anchors.fill: parent
    anchors.margins: focused ? -6 : 0

    // Gold glow. The accent is the only chromatic ink in the system, so focus
    // is the one thing that lights up.
    Rectangle {
        anchors.fill: parent
        visible: root.focused
        radius: root.frameRadius + 6
        color: "transparent"
        border.width: 3
        border.color: Theme.focus
        layer.enabled: root.focused
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(Theme.focus.r, Theme.focus.g, Theme.focus.b, 0.38)
            shadowBlur: 0.72
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 8
        }
    }

    // Inner hairline separates the gold ring from busy artwork underneath.
    Rectangle {
        anchors.fill: parent
        anchors.margins: root.focused ? 5 : 0
        radius: root.frameRadius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.88)
        visible: root.focused
    }

    Behavior on anchors.margins {
        NumberAnimation { duration: Theme.focusDuration; easing.type: Easing.OutCubic }
    }
}
