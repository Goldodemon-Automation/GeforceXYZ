import QtQuick
import QtQuick.Controls
import OpenNOW

AbstractButton {
    id: control
    signal valueChangedByUser(bool value)

    implicitWidth: DesktopTokens.px(38)
    implicitHeight: DesktopTokens.px(20)
    hoverEnabled: true
    Accessible.role: Accessible.CheckBox
    onClicked: valueChangedByUser(!checked)

    background: Rectangle {
        radius: height / 2
        color: control.checked ? (control.down ? Qt.darker(Theme.focus, 1.1) : Theme.focus)
                               : DesktopTokens.raisedStrong
        border.width: control.activeFocus ? 2 : control.checked ? 0 : 1
        border.color: control.activeFocus ? DesktopTokens.focus : DesktopTokens.edgeInk
        Behavior on color { ColorAnimation { duration: Theme.focusDuration } }
    }

    Rectangle {
        width: DesktopTokens.px(16)
        height: width
        radius: width / 2
        y: (control.height - height) / 2
        x: control.checked ? control.width - width - DesktopTokens.px(2) : DesktopTokens.px(2)
        color: control.checked ? Theme.focusText : DesktopTokens.textBody
        Behavior on x {
            NumberAnimation {
                duration: AppController.reducedMotion ? 0 : 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
