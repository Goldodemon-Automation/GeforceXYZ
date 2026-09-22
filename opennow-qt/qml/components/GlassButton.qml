import QtQuick
import QtQuick.Controls
import OpenNOW

Button {
    id: root
    property string glyph: "A"
    property string shortcutText: ""
    property bool primary: false
    property bool danger: false
    property bool currentItem: false
    highlighted: activeFocus || currentItem

    implicitHeight: 52
    leftPadding: 16
    rightPadding: 26
    focusPolicy: Qt.StrongFocus
    Accessible.name: I18n.source(text, I18n.revision) + (shortcutText !== "" ? " · " + shortcutText : "")
    Accessible.role: Accessible.Button

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (!event.isAutoRepeat)
                root.click()
            event.accepted = true
        }
    }

    // One primary action per screen wears the gold fill; everything else is a
    // black glass pill with a hairline seam.
    readonly property color fill: root.primary ? Theme.focus
        : root.danger ? Qt.rgba(Theme.coral.r, Theme.coral.g, Theme.coral.b, root.activeFocus ? 0.26 : 0.14)
                      : root.highlighted ? Qt.rgba(1, 1, 1, Theme.lightMode ? 0.10 : 0.14) : Theme.glassStrong
    readonly property color ink: root.primary ? Theme.focusText : root.danger ? Theme.coral : Theme.label

    background: Rectangle {
        radius: height / 2
        color: root.fill
        border.color: root.highlighted ? Theme.focus : root.danger ? Theme.coral : Theme.seam
        border.width: root.highlighted ? 2 : DesktopTokens.hairline
        Behavior on color { ColorAnimation { duration: Theme.focusDuration } }
        Behavior on border.color { ColorAnimation { duration: Theme.focusDuration } }
    }

    contentItem: Row {
        spacing: 12
        ControllerGlyph {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.glyph !== ""
            glyph: root.glyph
            label: ""
            glyphSize: 28
            glyphColor: root.ink
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: I18n.source(root.text, I18n.revision)
            color: root.ink
            font.family: Theme.bodyFont
            font.pixelSize: 16
            font.weight: Font.Bold
        }
        KeyboardGlyph {
            visible: root.shortcutText !== ""
            anchors.verticalCenter: parent.verticalCenter
            shortcut: root.shortcutText
            keySize: 26
            ink: root.ink
        }
    }
}
