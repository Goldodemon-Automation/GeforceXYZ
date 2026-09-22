import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OpenNOW

// Game store accounts. Each row names the linked identity, lists what the store
// supports, and offers the actions the connection payload allows.
DesktopSettingsPanel {
    id: page
    required property real availableWidth
    required property var settingsScreen

    width: page.availableWidth
    paperStyle: true

    DesktopSettingsSection {
        text: qsTr("Game store accounts")
        detail: ShellStore.gameAccounts.length > 0
            ? qsTr("%1 of %2 stores connected").arg(page.connectedCount()).arg(ShellStore.gameAccounts.length)
            : ""
        actionText: qsTr("Learn more")
        onActionRequested: AppController.openExternalUrl("https://www.nvidia.com/en-us/geforce-now/support/")
    }

    function connectedCount() {
        const accounts = ShellStore.gameAccounts || []
        let count = 0
        for (let i = 0; i < accounts.length; ++i) {
            if (accounts[i].isConnected === true || accounts[i].status === "connected")
                ++count
        }
        return count
    }

    Repeater {
        model: ShellStore.gameAccounts
        delegate: Item {
            id: storeRow
            required property int index
            required property var modelData
            readonly property var actions: page.settingsScreen.storeActions(modelData)
            readonly property var bulletLines: page.settingsScreen.storeBullets(modelData)
            readonly property bool busy: ShellStore.gameAccountsState === "loading"

            width: page.width
            height: Math.max(DesktopTokens.px(58), textColumn.implicitHeight + DesktopTokens.px(28))

            Image {
                id: storeMark
                x: 0
                anchors.verticalCenter: parent.verticalCenter
                width: DesktopTokens.px(22)
                height: width
                source: page.settingsScreen.storeIcon(storeRow.modelData)
                sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Column {
                id: textColumn
                x: DesktopTokens.px(40)
                width: Math.max(0, storeRow.width - x - actionRow.width - DesktopTokens.px(20))
                anchors.verticalCenter: parent.verticalCenter
                spacing: DesktopTokens.px(2)
                Text {
                    width: parent.width
                    text: page.settingsScreen.storeTitle(storeRow.modelData)
                    elide: Text.ElideRight
                    color: DesktopTokens.text
                    font.family: DesktopTokens.bodyFont
                    font.pixelSize: DesktopTokens.px(15)
                    font.weight: Font.Medium
                }
                Repeater {
                    model: storeRow.bulletLines
                    delegate: DesktopSettingsBullet {
                        required property var modelData
                        width: textColumn.width
                        text: modelData.text
                        detail: modelData.detail || ""
                        supported: modelData.supported
                        informational: modelData.informational === true
                    }
                }
            }

            Row {
                id: actionRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: DesktopTokens.px(4)
                Repeater {
                    model: storeRow.actions
                    delegate: DesktopSettingsButton {
                        required property var modelData
                        enabled: !storeRow.busy
                        opacity: enabled ? 1 : 0.5
                        text: modelData.label
                        onClicked: page.settingsScreen.runStoreAction(storeRow.modelData, modelData.id)
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: DesktopTokens.seamSoft
                visible: storeRow.index < ShellStore.gameAccounts.length - 1
            }
        }
    }

    Text {
        width: parent.width
        visible: ShellStore.gameAccounts.length === 0
        topPadding: DesktopTokens.px(10)
        wrapMode: Text.WordWrap
        text: ShellStore.signedIn
            ? qsTr("No game stores are linked to this NVIDIA account yet.")
            : qsTr("Sign in to see the game stores linked to your NVIDIA account.")
        color: DesktopTokens.textMuted
        font.family: DesktopTokens.bodyFont
        font.pixelSize: DesktopTokens.px(13)
    }

    Item {
        id: syncRow
        width: parent.width
        height: DesktopTokens.px(48)
        Text {
            anchors.left: parent.left
            anchors.right: syncButton.left
            anchors.rightMargin: DesktopTokens.px(16)
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: ShellStore.gameAccountMessage !== ""
                ? ShellStore.gameAccountMessage
                : qsTr("Linking happens on NVIDIA's side.")
            color: DesktopTokens.textMuted
            font.family: DesktopTokens.bodyFont
            font.pixelSize: DesktopTokens.px(12.5)
        }
        DesktopSettingsButton {
            id: syncButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            enabled: ShellStore.gameAccountsState !== "loading"
            opacity: enabled ? 1 : 0.5
            text: ShellStore.gameAccountsState === "loading" ? qsTr("Syncing…") : qsTr("Sync now")
            onClicked: ShellStore.refreshGameAccounts()
        }
    }
}
