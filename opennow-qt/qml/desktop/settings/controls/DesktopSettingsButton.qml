import QtQuick
import QtQuick.Controls
import OpenNOW

// Settings actions are text: uppercase, no fill, no border, brighter on hover.
// `primary` keeps one filled gold button for pages that need a single loud
// action, and `menu` renders a value plus caret for selectors.
Button {
    id: control
    property bool primary: false
    property bool danger: false
    property bool compact: false
    property bool menu: false
    property string suffix: ""
    property string keySequence: ""

    implicitHeight: menu ? DesktopTokens.px(34) : compact ? DesktopTokens.px(28) : DesktopTokens.px(34)
    // The floor keeps a shortcut's keycap row readable: the glyph needs the width
    // even when the label itself is short.
    implicitWidth: Math.max(compact ? 68 : 84, (keySequence !== "" ? bindingGlyph.implicitWidth : label.implicitWidth) + 22
        + (menu ? 14 : 0) + (suffix !== "" ? suffixGlyph.implicitWidth + 8 : 0))
    hoverEnabled: true
    padding: 0
    leftPadding: 10
    rightPadding: 10
    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        radius: DesktopTokens.px(4)
        color: control.primary ? (control.down ? Qt.darker(Theme.focus, 1.08) : Theme.focus)
             : control.danger ? Qt.rgba(1, 0.32, 0.32, control.down ? 0.16 : control.hovered ? 0.10 : 0.06)
             : control.down || control.hovered || control.activeFocus ? DesktopTokens.raised : "transparent"
        border.width: control.activeFocus ? 1 : 0
        border.color: control.primary ? Qt.rgba(1, 1, 1, 0.45) : DesktopTokens.focus
        Behavior on color { ColorAnimation { duration: Theme.focusDuration } }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8
            Text {
                id: label
                visible: control.keySequence === ""
                text: control.text
                width: Math.max(0, Math.min(implicitWidth, control.availableWidth
                    - (control.menu ? 14 : 0) - (control.suffix !== "" ? suffixGlyph.implicitWidth + 8 : 0)))
                elide: Text.ElideRight
                color: control.primary ? Theme.focusText : control.danger ? Theme.coral : DesktopTokens.text
                font.family: Theme.bodyFont
                font.pixelSize: DesktopTokens.px(12.5)
                font.weight: Font.DemiBold
                // Selector values stay as typed; action verbs read as uppercase.
                font.letterSpacing: control.menu ? 0 : (control.primary ? 0.1 : 0.7)
                font.capitalization: control.menu ? Font.MixedCase : Font.AllUppercase
                anchors.verticalCenter: parent.verticalCenter
            }
            KeyboardGlyph {
                id: bindingGlyph
                visible: control.keySequence !== ""
                shortcut: control.keySequence
                keySize: DesktopTokens.px(22)
                ink: control.primary ? Theme.focusText : DesktopTokens.text
                anchors.verticalCenter: parent.verticalCenter
            }
            KeyboardGlyph {
                id: suffixGlyph
                visible: control.suffix !== ""
                shortcut: control.suffix
                keySize: 18
                ink: control.primary ? Theme.focusText : DesktopTokens.textMuted
                anchors.verticalCenter: parent.verticalCenter
            }
            DesktopSettingsIcon {
                visible: control.menu
                width: DesktopTokens.px(13)
                height: width
                glyph: "chevronDown"
                ink: control.primary ? Theme.focusText : DesktopTokens.textBody
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
