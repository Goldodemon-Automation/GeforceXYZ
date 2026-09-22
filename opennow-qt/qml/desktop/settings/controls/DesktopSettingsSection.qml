import QtQuick
import QtQuick.Controls
import OpenNOW

// Group heading inside a settings page, with an optional action on the right
// (LEARN MORE, SYNC NOW) that reads as a text button, never a filled control.
Item {
    id: root
    property string text: ""
    property string detail: ""
    property string actionText: ""
    property bool actionEnabled: true
    width: parent.width
    height: root.detail !== "" ? DesktopTokens.px(62) : DesktopTokens.px(44)
    // Pages written before this restyle use ALL CAPS labels. Render those as a
    // small eyebrow and sentence-case headings as a heading, so no page needs
    // its source text rewritten to match.
    readonly property bool eyebrow: text !== "" && text === text.toUpperCase() && text !== text.toLowerCase()
    signal actionRequested()

    Text {
        id: sectionTitle
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: DesktopTokens.px(14)
        text: root.text
        color: root.eyebrow ? DesktopTokens.textMuted : DesktopTokens.text
        font.family: Theme.bodyFont
        font.pixelSize: DesktopTokens.px(root.eyebrow ? 11.5 : 15)
        font.weight: Font.DemiBold
        font.letterSpacing: root.eyebrow ? 1.0 : 0.1
    }

    Text {
        anchors.left: parent.left
        anchors.top: sectionTitle.bottom
        anchors.topMargin: DesktopTokens.px(2)
        visible: root.detail !== ""
        text: root.detail
        color: DesktopTokens.textMuted
        font.family: Theme.bodyFont
        font.pixelSize: DesktopTokens.px(12)
    }

    AbstractButton {
        id: actionButton
        visible: root.actionText !== ""
        enabled: root.actionEnabled
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: DesktopTokens.px(12)
        width: implicitWidth
        height: DesktopTokens.px(24)
        hoverEnabled: true
        opacity: enabled ? 1 : 0.5
        Accessible.name: root.actionText
        onClicked: root.actionRequested()
        contentItem: Text {
            text: root.actionText
            color: actionButton.hovered || actionButton.activeFocus ? DesktopTokens.text : DesktopTokens.textBody
            font.family: Theme.bodyFont
            font.pixelSize: DesktopTokens.px(12)
            font.weight: Font.DemiBold
            font.letterSpacing: 0.7
            font.capitalization: Font.AllUppercase
            anchors.centerIn: parent
        }
        background: Item {
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: DesktopTokens.px(3)
                width: parent.width
                height: 1
                visible: actionButton.hovered || actionButton.activeFocus
                color: DesktopTokens.textBody
            }
        }
    }
}
