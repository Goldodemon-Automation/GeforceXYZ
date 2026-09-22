import QtQuick
import QtQuick.Controls
import OpenNOW

// One labelled setting. On a settings page (paperStyle) it is a flat row:
// label and description on the left, the value or control on the right, and a
// hairline under it. Store rows add their logo to the left of the label.
Item {
    id: root
    property bool paperStyle: false
    property string glyph: ""
    property bool expanded: false
    property bool expandable: false
    property bool clickable: false
    signal expansionRequested()
    property string title: ""
    property string description: ""
    property string value: ""
    property int rowHeight: root.paperStyle ? DesktopTokens.settingsRowHeight : DesktopTokens.rowHeight
    property bool showDivider: true
    property string leadingLetter: ""
    property url leadingIcon: ""
    property color leadingColor: DesktopTokens.raised
    // Paper rows carry their identity in the title; only real artwork (a store
    // mark) earns a leading slot there.
    readonly property bool hasLeading: root.leadingLetter !== ""
        || root.leadingIcon.toString() !== "" || (!root.paperStyle && root.glyph !== "")
    readonly property int leadingSize: root.paperStyle ? DesktopTokens.px(22) : DesktopTokens.px(36)
    readonly property int labelsLeft: root.hasLeading ? root.leadingSize + DesktopTokens.px(14) : 0
    readonly property int trailingRightMargin: (root.expandable ? DesktopTokens.px(30) : 0)
        + (root.paperStyle ? DesktopTokens.px(2) : 0)
    default property alias trailing: trailingSlot.data

    readonly property bool stacked: width < trailingSlot.implicitWidth + (hasLeading ? 340 : 290)
    implicitHeight: Math.max(rowHeight, stacked ? labels.implicitHeight + trailingSlot.height + 28
        : labels.implicitHeight + (paperStyle ? 20 : 24))
    signal activated()

    Rectangle {
        id: leadingTile
        visible: root.hasLeading
        x: 0
        y: root.stacked ? 14 : (parent.height - height) / 2
        width: root.leadingSize
        height: width
        radius: root.paperStyle ? width / 2 : DesktopTokens.px(10)
        color: root.paperStyle ? "transparent" : root.expanded ? Theme.focus : root.leadingColor
        border.width: root.paperStyle ? 0 : 1
        border.color: Theme.seam
        DesktopSettingsIcon {
            anchors.centerIn: parent
            width: root.paperStyle ? DesktopTokens.px(16) : 20
            height: width
            visible: root.glyph !== "" && root.leadingIcon.toString() === ""
            glyph: root.glyph
            ink: root.expanded ? Theme.focusText : Theme.label
        }
        Image {
            anchors.centerIn: parent
            width: root.paperStyle ? parent.width : 19
            height: width
            source: root.leadingIcon
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: root.leadingIcon.toString() !== ""
        }
        Text {
            anchors.centerIn: parent
            text: root.leadingLetter
            visible: root.leadingIcon.toString() === "" && root.glyph === ""
            color: Theme.label
            font.family: DesktopTokens.bodyFont
            font.pixelSize: 16
            font.weight: Font.Black
        }
    }

    Column {
        id: labels
        anchors.left: parent.left
        anchors.leftMargin: root.labelsLeft
        anchors.right: root.stacked ? parent.right : trailingSlot.left
        anchors.rightMargin: root.trailingRightMargin + DesktopTokens.px(16)
        y: root.stacked ? 12 : (parent.height - height) / 2
        spacing: 1
        Text {
            width: parent.width
            text: root.title
            color: Theme.label
            font.family: Theme.bodyFont
            font.pixelSize: DesktopTokens.px(root.paperStyle ? 15 : 14)
            font.weight: root.paperStyle ? Font.Medium : Font.Bold
            wrapMode: Text.WordWrap
        }
        Text {
            width: parent.width
            visible: root.description !== ""
            text: root.description
            color: DesktopTokens.textMuted
            font.family: Theme.bodyFont
            font.pixelSize: DesktopTokens.px(root.paperStyle ? 13 : 12)
            wrapMode: Text.WordWrap
        }
    }

    Row {
        id: trailingSlot
        anchors.right: parent.right
        anchors.rightMargin: root.trailingRightMargin
        y: root.stacked ? labels.y + labels.height + 12 : (parent.height - height) / 2
        spacing: DesktopTokens.px(10)
        height: DesktopTokens.controlHeight

        add: Transition {
            ScriptAction { script: root.centerTrailing() }
        }

        Text {
            visible: root.value !== ""
            text: root.value
            color: Theme.label
            font.family: DesktopTokens.monoFont
            font.pixelSize: DesktopTokens.px(13)
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    AbstractButton {
        visible: root.paperStyle && root.expandable
        anchors.right: parent.right
        anchors.rightMargin: DesktopTokens.px(2)
        anchors.verticalCenter: parent.verticalCenter
        width: DesktopTokens.px(26)
        height: width
        hoverEnabled: true
        Accessible.name: root.title
        onClicked: root.expansionRequested()
        background: Rectangle {
            radius: DesktopTokens.px(6)
            color: parent.activeFocus || parent.hovered ? DesktopTokens.raised : "transparent"
        }
        DesktopSettingsIcon {
            anchors.centerIn: parent
            width: DesktopTokens.px(15)
            height: width
            glyph: "chevronDown"
            rotation: root.expanded ? 180 : 0
            ink: root.expanded ? DesktopTokens.text : DesktopTokens.textMuted
            Behavior on rotation { enabled: !AppController.reducedMotion; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickable
        z: -1
        hoverEnabled: root.clickable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    function centerTrailing() {
        for (let i = 0; i < trailingSlot.children.length; ++i) {
            const item = trailingSlot.children[i]
            if (item)
                item.anchors.verticalCenter = trailingSlot.verticalCenter
        }
    }

    Component.onCompleted: centerTrailing()

    Rectangle {
        visible: root.showDivider
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: DesktopTokens.seamSoft
    }
}
