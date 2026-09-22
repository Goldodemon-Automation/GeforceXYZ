import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OpenNOW

// Account: who is signed in, what the membership covers right now, and how much
// playtime is left. Every value comes from the account services payload, so the
// page reads correctly for any tier, billing period or playtime balance.
DesktopSettingsPanel {
    id: profilePanel
    required property real availableWidth
    required property var settingsScreen

    width: profilePanel.availableWidth
    paperStyle: true

    Item {
        id: identityRow
        width: parent.width
        height: DesktopTokens.px(68)

        Rectangle {
            id: avatar
            anchors.verticalCenter: parent.verticalCenter
            width: DesktopTokens.px(40)
            height: width
            radius: width / 2
            color: DesktopTokens.raisedStrong
            Text {
                anchors.centerIn: parent
                text: profilePanel.settingsScreen.profileInitial()
                color: DesktopTokens.text
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(16)
                font.weight: Font.DemiBold
            }
        }

        Column {
            anchors.left: avatar.right
            anchors.leftMargin: DesktopTokens.px(14)
            anchors.right: identityActions.left
            anchors.rightMargin: DesktopTokens.px(16)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                width: parent.width
                text: profilePanel.settingsScreen.profileName()
                elide: Text.ElideRight
                color: DesktopTokens.text
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(16)
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                text: profilePanel.settingsScreen.profileSubtitle()
                elide: Text.ElideRight
                color: DesktopTokens.textMuted
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(12.5)
            }
        }

        Row {
            id: identityActions
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: DesktopTokens.px(8)
            DesktopSettingsButton {
                text: ShellStore.signedIn ? qsTr("Log out") : qsTr("Sign in")
                onClicked: ShellStore.signedIn ? ShellStore.logout() : AppController.navigate("sign-in")
            }
            DesktopSettingsButton {
                text: qsTr("View account")
                onClicked: Qt.openUrlExternally("https://www.nvidia.com/en-us/account/")
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: DesktopTokens.edgeInk }

    Item {
        id: updatedRow
        width: parent.width
        height: DesktopTokens.px(48)
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: profilePanel.settingsScreen.accountUpdatedText()
            color: DesktopTokens.textMuted
            font.family: DesktopTokens.bodyFont
            font.pixelSize: DesktopTokens.px(13)
        }
        DesktopSettingsButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            enabled: ShellStore.signedIn
            text: ShellStore.subscriptionRequestId !== "" ? qsTr("Refreshing…") : qsTr("Refresh details")
            onClicked: ShellStore.refreshAccountServices()
        }
    }

    Item {
        id: membershipRow
        width: parent.width
        height: DesktopTokens.px(58)
        Column {
            anchors.left: parent.left
            anchors.right: membershipAction.left
            anchors.rightMargin: DesktopTokens.px(16)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                width: parent.width
                text: profilePanel.settingsScreen.membershipTitle()
                elide: Text.ElideRight
                color: DesktopTokens.text
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(15)
                font.weight: Font.Medium
            }
            Text {
                width: parent.width
                visible: text !== ""
                text: profilePanel.settingsScreen.billingText()
                elide: Text.ElideRight
                color: DesktopTokens.textMuted
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(12.5)
            }
        }
        DesktopSettingsButton {
            id: membershipAction
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Manage")
            onClicked: Qt.openUrlExternally("https://www.nvidia.com/en-us/account/")
        }
    }

    Item {
        id: playtimeRow
        width: parent.width
        height: playtimeActions.y + playtimeActions.height + DesktopTokens.px(4)

        Item {
            id: playtimeHeader
            width: parent.width
            height: DesktopTokens.px(22)
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Playtime remaining")
                color: DesktopTokens.text
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(15)
                font.weight: Font.Medium
            }
            DesktopSettingsButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Learn more")
                onClicked: profilePanel.settingsScreen.openMembershipPage()
            }
        }

        Text {
            id: playtimeReset
            anchors.top: playtimeHeader.bottom
            width: parent.width
            visible: text !== ""
            text: profilePanel.settingsScreen.playtimeResetText()
            elide: Text.ElideRight
            color: DesktopTokens.textMuted
            font.family: DesktopTokens.bodyFont
            font.pixelSize: DesktopTokens.px(12.5)
        }

        Row {
            id: remainingRow
            anchors.top: playtimeReset.visible ? playtimeReset.bottom : playtimeHeader.bottom
            anchors.topMargin: DesktopTokens.px(12)
            spacing: DesktopTokens.px(10)
            DesktopSettingsIcon {
                anchors.verticalCenter: parent.verticalCenter
                width: DesktopTokens.px(18)
                height: width
                glyph: "clock"
                ink: DesktopTokens.textBody
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: profilePanel.settingsScreen.playtimeRemainingText()
                color: DesktopTokens.text
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(16)
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            id: playtimeTrack
            anchors.top: remainingRow.bottom
            anchors.topMargin: DesktopTokens.px(12)
            width: parent.width
            height: DesktopTokens.px(6)
            radius: height / 2
            color: DesktopTokens.raisedStrong
            visible: ShellStore.subscription !== null
            Rectangle {
                width: Math.round(parent.width * profilePanel.settingsScreen.playtimeFraction())
                height: parent.height
                radius: parent.radius
                color: DesktopTokens.focus
                Behavior on width { NumberAnimation { duration: DesktopTokens.motionDuration; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            id: playtimeTotal
            anchors.top: playtimeTrack.visible ? playtimeTrack.bottom : remainingRow.bottom
            anchors.topMargin: DesktopTokens.px(10)
            width: parent.width
            text: profilePanel.settingsScreen.playtimeTotalText()
            elide: Text.ElideRight
            color: DesktopTokens.textMuted
            font.family: DesktopTokens.bodyFont
            font.pixelSize: DesktopTokens.px(13)
        }

        Row {
            id: playtimeActions
            anchors.top: playtimeTotal.bottom
            anchors.topMargin: DesktopTokens.px(10)
            anchors.right: parent.right
            spacing: DesktopTokens.px(8)
            DesktopSettingsButton {
                text: qsTr("Playtime details")
                enabled: ShellStore.signedIn
                onClicked: profilePanel.settingsScreen.advancedOpen = true
            }
            DesktopSettingsButton {
                text: qsTr("Add playtime")
                onClicked: profilePanel.settingsScreen.openMembershipPage()
            }
        }
    }

    DesktopSettingsSection {
        text: qsTr("Your membership includes")
        actionText: qsTr("Upgrade")
        actionEnabled: ShellStore.signedIn
        onActionRequested: profilePanel.settingsScreen.openMembershipPage()
    }

    Repeater {
        model: profilePanel.settingsScreen.entitlementBullets()
        delegate: DesktopSettingsBullet {
            required property var modelData
            width: profilePanel.width
            text: modelData.text
            detail: modelData.detail || ""
            supported: modelData.supported
        }
    }

    Text {
        width: parent.width
        visible: profilePanel.settingsScreen.entitlementBullets().length === 0
        topPadding: DesktopTokens.px(4)
        bottomPadding: DesktopTokens.px(8)
        wrapMode: Text.WordWrap
        text: ShellStore.signedIn
            ? qsTr("Entitlement details are unavailable for this account right now.")
            : qsTr("Sign in with your NVIDIA account to load your membership.")
        color: DesktopTokens.textMuted
        font.family: DesktopTokens.bodyFont
        font.pixelSize: DesktopTokens.px(13)
    }

    Rectangle { width: parent.width; height: 1; color: DesktopTokens.edgeInk }

    DesktopSettingsRow {
        objectName: "accountPromoCode"
        width: parent.width
        paperStyle: true
        clickable: true
        title: qsTr("Activate Promo Code")
        onActivated: AppController.openExternalUrl("https://www.nvidia.com/en-us/geforce-now/redeem/")
        DesktopSettingsIcon {
            width: DesktopTokens.px(15)
            height: width
            glyph: "external"
            ink: DesktopTokens.textBody
        }
    }

    DesktopSettingsRow {
        objectName: "accountGiftCard"
        width: parent.width
        paperStyle: true
        clickable: true
        title: qsTr("Activate Gift Card")
        onActivated: AppController.openExternalUrl("https://www.nvidia.com/en-us/geforce-now/redeem/")
        DesktopSettingsIcon {
            width: DesktopTokens.px(15)
            height: width
            glyph: "external"
            ink: DesktopTokens.textBody
        }
    }

    DesktopSettingsSection { text: qsTr("Privacy") }

    DesktopSettingsRow {
        objectName: "accountActivitySharing"
        width: parent.width
        paperStyle: true
        title: qsTr("Discord rich presence")
        description: qsTr("Share the game you are playing on your Discord profile")
        DesktopSettingsToggle {
            checked: profilePanel.settingsScreen.boolSetting("discordRichPresence", false)
            onValueChangedByUser: value => profilePanel.settingsScreen.setSetting("discordRichPresence", value)
        }
    }

    DesktopSettingsRow {
        objectName: "accountCrashReports"
        width: parent.width
        paperStyle: true
        title: qsTr("Crash reports")
        description: qsTr("Optional error reporting")
        showDivider: false
        DesktopSettingsToggle {
            checked: ShellStore.settings.errorReportingConsent === "granted"
            onValueChangedByUser: value => profilePanel.settingsScreen.setSetting("errorReportingConsent", value ? "granted" : "denied")
        }
    }
}
