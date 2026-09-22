import QtQuick
import QtQuick.Controls
import OpenNOW

// Flat disclosure header: a label, an optional hint, and one chevron. Used for
// the extra groups a page keeps out of the way until they are needed.
AbstractButton {
    id: root
    property string detail: ""
    property bool expanded: false
    width: parent.width
    implicitHeight: DesktopTokens.px(48)
    hoverEnabled: true
    Accessible.checked: root.expanded
    background: Rectangle {
        radius: DesktopTokens.px(4)
        color: root.hovered || root.activeFocus ? DesktopTokens.raised : "transparent"
        border.width: root.activeFocus ? 1 : 0
        border.color: DesktopTokens.focus
    }
    contentItem: Item {
        Text {
            id: title
            x: DesktopTokens.px(2)
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Advanced")
            color: DesktopTokens.text
            font.family: Theme.bodyFont
            font.pixelSize: DesktopTokens.px(14)
            font.weight: Font.Medium
        }
        Text {
            anchors.left: title.right
            anchors.leftMargin: DesktopTokens.px(10)
            anchors.right: arrow.left
            anchors.rightMargin: DesktopTokens.px(14)
            anchors.verticalCenter: parent.verticalCenter
            text: root.detail
            elide: Text.ElideRight
            color: DesktopTokens.textMuted
            font.family: Theme.bodyFont
            font.pixelSize: DesktopTokens.px(12.5)
        }
        DesktopSettingsIcon {
            id: arrow
            anchors.right: parent.right
            anchors.rightMargin: DesktopTokens.px(4)
            anchors.verticalCenter: parent.verticalCenter
            width: DesktopTokens.px(15)
            height: width
            glyph: "chevronDown"
            rotation: root.expanded ? 180 : 0
            ink: root.expanded ? DesktopTokens.text : DesktopTokens.textMuted
            Behavior on rotation { enabled: !AppController.reducedMotion; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }
    }
}
