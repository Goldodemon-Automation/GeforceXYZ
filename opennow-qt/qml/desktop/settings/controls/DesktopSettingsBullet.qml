import QtQuick
import OpenNOW

// One capability line under an account or store row: a small state mark, the
// capability, then a muted qualifier ("– Not supported", "· Updated 3 months
// ago"). Quiet by design: these lines never compete with the row title.
Row {
    id: root
    property string text: ""
    property string detail: ""
    property bool supported: true
    property bool informational: false
    spacing: DesktopTokens.px(8)
    height: DesktopTokens.px(19)

    Item {
        width: DesktopTokens.px(14)
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        DesktopSettingsIcon {
            visible: !root.informational
            anchors.centerIn: parent
            width: DesktopTokens.px(11)
            height: width
            glyph: root.supported ? "check" : "chevron"
            ink: root.supported ? DesktopTokens.textBody : DesktopTokens.textFaint
        }
        Rectangle {
            visible: root.informational
            anchors.centerIn: parent
            width: DesktopTokens.px(10)
            height: 1
            color: DesktopTokens.textFaint
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: root.supported ? DesktopTokens.textBody : DesktopTokens.textMuted
        font.family: DesktopTokens.bodyFont
        font.pixelSize: DesktopTokens.px(13)
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.detail !== ""
        text: root.detail
        color: DesktopTokens.textFaint
        font.family: DesktopTokens.bodyFont
        font.pixelSize: DesktopTokens.px(13)
    }
}
