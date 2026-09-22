import QtQuick
import QtQuick.Controls
import OpenNOW

Switch {
    id: root
    implicitWidth: 60
    implicitHeight: 34
    focusPolicy: Qt.StrongFocus
    indicator: Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.focus : (Theme.lightMode ? Qt.rgba(0, 0, 0, 0.16) : Qt.rgba(1, 1, 1, 0.18))
        border.color: root.activeFocus ? Theme.focus : Theme.seam
        border.width: root.activeFocus ? 2 : 1
        Rectangle {
            width: 26; height: 26; radius: 13
            x: root.checked ? parent.width - width - 4 : 4
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked ? Theme.focusText : Theme.face
            Behavior on x { NumberAnimation { duration: Theme.focusDuration; easing.type: Easing.OutCubic } }
        }
        Behavior on color { ColorAnimation { duration: Theme.focusDuration } }
    }
    contentItem: Item {}
}
