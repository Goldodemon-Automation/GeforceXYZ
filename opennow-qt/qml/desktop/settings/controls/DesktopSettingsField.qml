import QtQuick
import QtQuick.Controls
import OpenNOW

TextField {
    id: control
    implicitWidth: DesktopTokens.px(260)
    implicitHeight: DesktopTokens.px(40)
    color: Theme.label
    placeholderTextColor: Theme.textMuted
    selectionColor: Theme.focus
    selectedTextColor: Theme.focusText
    font.family: Theme.bodyFont
    font.pixelSize: DesktopTokens.px(13)
    leftPadding: DesktopTokens.px(14)
    rightPadding: DesktopTokens.px(14)
    selectByMouse: true
    background: Rectangle {
        radius: DesktopTokens.px(4)
        color: Theme.lightMode ? Qt.rgba(0, 0, 0, 0.04) : Qt.rgba(0, 0, 0, 0.3)
        border.width: 1
        border.color: control.activeFocus ? Theme.focus : DesktopTokens.edgeInk
    }
}
