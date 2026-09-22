import QtQuick
import QtQuick.Controls
import OpenNOW

// Chevron · value · chevron, right-aligned in the row's value column. No pill:
// the selector reads as a value you can step through, like the reference UI.
Item {
    id: root
    property string text: ""
    property bool previousEnabled: true
    property bool nextEnabled: true
    signal previous()
    signal next()
    signal openRequested()
    function focusSelector() { selector.forceActiveFocus() }
    implicitWidth: DesktopTokens.px(200)
    implicitHeight: DesktopTokens.px(34)

    AbstractButton {
        id: previousButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: DesktopTokens.px(26)
        height: width
        enabled: root.previousEnabled
        Accessible.name: qsTr("Previous option")
        onClicked: root.previous()
        background: Rectangle {
            radius: DesktopTokens.px(4)
            color: parent.activeFocus || parent.hovered ? DesktopTokens.raised : "transparent"
        }
        contentItem: DesktopSettingsIcon {
            anchors.centerIn: parent
            width: DesktopTokens.px(14)
            height: width
            glyph: "chevron"
            rotation: 180
            ink: DesktopTokens.textBody
            opacity: previousButton.enabled ? 1 : 0.3
        }
    }

    AbstractButton {
        id: selector
        anchors.centerIn: parent
        width: Math.max(DesktopTokens.px(60), parent.width - DesktopTokens.px(60))
        height: DesktopTokens.px(30)
        Accessible.name: root.text
        onClicked: root.openRequested()
        background: Rectangle {
            radius: DesktopTokens.px(4)
            color: parent.activeFocus || parent.hovered ? DesktopTokens.raised : "transparent"
            border.width: parent.activeFocus ? 1 : 0
            border.color: DesktopTokens.focus
        }
        contentItem: Text {
            anchors.centerIn: parent
            width: Math.max(0, selector.width - DesktopTokens.px(8))
            text: root.text
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: DesktopTokens.text
            font.family: Theme.bodyFont
            font.pixelSize: DesktopTokens.px(14)
            font.weight: Font.Medium
        }
    }

    AbstractButton {
        id: nextButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: DesktopTokens.px(26)
        height: width
        enabled: root.nextEnabled
        Accessible.name: qsTr("Next option")
        onClicked: root.next()
        background: Rectangle {
            radius: DesktopTokens.px(4)
            color: parent.activeFocus || parent.hovered ? DesktopTokens.raised : "transparent"
        }
        contentItem: DesktopSettingsIcon {
            anchors.centerIn: parent
            width: DesktopTokens.px(14)
            height: width
            glyph: "chevron"
            ink: DesktopTokens.textBody
            opacity: nextButton.enabled ? 1 : 0.3
        }
    }
}
