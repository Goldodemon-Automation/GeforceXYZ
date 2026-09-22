import QtQuick
import QtQuick.Controls
import OpenNOW

// Desktop chrome: one full-width bar carries the menu button, the page name,
// search and the account chip, and navigation lives in a drawer that opens
// over the page. Content is never inset, so pages own the whole window.
FocusScope {
    id: root
    objectName: "desktopShell"
    default property alias contentData: contentHost.data
    property string route: "home"
    readonly property bool settingsPage: route.indexOf("settings") === 0
    property string title: qsTr("Home")
    property string subtitle: qsTr("Your library")
    property bool searchVisible: route !== "settings" && route.indexOf("settings-") !== 0 && route !== "friends"
    property string searchText: ""
    // The saved flag still means "collapsed": true hides the drawer, false
    // keeps it open on launch. The menu button writes the same flag back.
    readonly property bool drawerPinned: ShellStore.settings.desktopRailCollapsed === false
    property bool drawerOpen: false
    readonly property int maxTitleWidth: DesktopTokens.px(220)
    signal routeRequested(string route)
    signal consoleModeRequested()
    signal commandPaletteRequested()

    anchors.fill: parent
    focus: true

    function persistRailCollapsed(collapsed) {
        ShellStore.applySetting("desktopRailCollapsed", collapsed)
        ShellStore.setSetting("desktopRailCollapsed", collapsed)
    }

    function setDrawerOpen(open) {
        root.drawerOpen = open
        if (open === root.drawerPinned)
            root.persistRailCollapsed(!open)
    }

    function accountName() {
        const user = ShellStore.authSession && ShellStore.authSession.user ? ShellStore.authSession.user : null
        if (!ShellStore.signedIn || !user)
            return qsTr("Sign in")
        return String(user.displayName || user.email || qsTr("Account"))
    }

    function accountTier() {
        if (!ShellStore.signedIn)
            return qsTr("Not signed in")
        const sub = ShellStore.subscription
        const user = ShellStore.authSession && ShellStore.authSession.user ? ShellStore.authSession.user : null
        const tier = sub && sub.membershipTier ? sub.membershipTier : (user ? user.membershipTier : "")
        return tier ? DesktopTokens.displayCase(tier) : qsTr("Member")
    }

    function activeSessionPrompt() {
        const session = ShellStore.resumableSession
        if (!session)
            return ""
        const title = ShellStore.sessionGameTitle(session)
        return title
            ? qsTr("Active session: %1 · Resume?").arg(title)
            : qsTr("Active session running · Resume?")
    }

    Component.onCompleted: root.drawerOpen = root.drawerPinned

    DesktopBackdrop { anchors.fill: parent }

    Item {
        id: main
        x: 0
        width: root.width
        height: root.height

        Rectangle {
            id: bar
            objectName: "desktopTopBar"
            width: parent.width
            height: DesktopTokens.barHeight
            color: DesktopTokens.bar
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: DesktopTokens.seamSoft }

            // The title band, the search band and the right cluster are all
            // computed from window width alone, so the search never depends on
            // the title's own width (which depends on the search).
            readonly property int titleLeft: menuButton.x + menuButton.width + DesktopTokens.px(12)
            readonly property int titleBandWidth: Math.round(Math.max(DesktopTokens.px(60),
                Math.min(root.maxTitleWidth, bar.width * 0.24,
                    bar.clusterLeft - DesktopTokens.px(22) - bar.resumeWidth - titleLeft
                        - DesktopTokens.px(144))))
            readonly property int searchBandLeft: titleLeft + titleBandWidth + DesktopTokens.px(24)
            readonly property int chipWidth: Math.round(Math.max(DesktopTokens.px(104),
                Math.min(DesktopTokens.px(200), bar.width * 0.22)))
            readonly property int helpWidth: DesktopTokens.px(34)
            readonly property int clusterWidth: helpWidth + DesktopTokens.px(4) + chipWidth
            readonly property int clusterLeft: bar.width - DesktopTokens.px(12) - clusterWidth
            readonly property int resumeWidth: Math.round(Math.min(DesktopTokens.px(200),
                Math.max(DesktopTokens.px(96), bar.width * 0.16)))
            readonly property int searchBandRight: activeSessionButton.visible
                ? activeSessionButton.x - DesktopTokens.px(12) : clusterLeft - DesktopTokens.px(8)

            AbstractButton {
                id: menuButton
                objectName: "desktopHeaderMenu"
                x: DesktopTokens.px(10)
                width: DesktopTokens.px(34)
                height: width
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                Accessible.name: qsTr("Navigation menu")
                Accessible.checked: root.drawerOpen
                onClicked: root.setDrawerOpen(!root.drawerOpen)
                background: Rectangle {
                    radius: DesktopTokens.px(6)
                    color: menuButton.hovered || menuButton.activeFocus ? DesktopTokens.raised : "transparent"
                }
                contentItem: DesktopSettingsIcon {
                    anchors.centerIn: parent
                    width: DesktopTokens.px(18)
                    height: width
                    glyph: "menu"
                    ink: DesktopTokens.text
                }
            }

            Item {
                id: heading
                objectName: "desktopHeaderHeading"
                x: menuButton.x + menuButton.width + DesktopTokens.px(12)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, (search.visible ? search.x : bar.clusterLeft - DesktopTokens.px(12)) - x - DesktopTokens.px(12))
                height: headerTitle.implicitHeight
                Text {
                    id: headerTitle
                    width: Math.min(implicitWidth, parent.width)
                    text: root.title
                    elide: Text.ElideRight
                    color: DesktopTokens.text
                    font.family: DesktopTokens.displayFont
                    font.pixelSize: DesktopTokens.px(17)
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.1
                }
            }

            TextField {
                id: search
                objectName: "desktopHeaderSearch"
                visible: root.searchVisible
                readonly property int bandWidth: Math.max(0, bar.searchBandRight - bar.searchBandLeft)
                readonly property int centeredX: Math.round(parent.width / 2 - width / 2)
                // Centred in the window while the band allows it, then pushed
                // inside the band so it can never reach the right cluster.
                width: Math.min(DesktopTokens.px(320), bandWidth)
                x: Math.max(bar.searchBandLeft,
                    Math.min(Math.max(bar.searchBandLeft, bar.searchBandRight - width), centeredX))
                height: DesktopTokens.px(34)
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: DesktopTokens.px(34)
                rightPadding: DesktopTokens.px(34)
                topPadding: 0
                bottomPadding: 0
                color: DesktopTokens.text
                placeholderText: root.route === "friends"
                    ? qsTr("Search friends") : root.route === "store"
                        ? qsTr("Search the store") : qsTr("Search games, stores, or genres")
                placeholderTextColor: DesktopTokens.textMuted
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(13)
                text: root.searchText
                selectByMouse: true
                background: Rectangle {
                    radius: DesktopTokens.px(6)
                    color: Theme.lightMode ? Theme.shell : Qt.rgba(0, 0, 0, 0.35)
                    border.width: 1
                    border.color: search.activeFocus ? DesktopTokens.focus : DesktopTokens.edgeInk
                }
                onTextChanged: root.searchText = text
                DesktopGlyph {
                    x: DesktopTokens.px(11)
                    anchors.verticalCenter: parent.verticalCenter
                    width: DesktopTokens.px(14)
                    height: width
                    icon: "desktop-search.svg"
                }
                KeyboardGlyph {
                    anchors.right: parent.right
                    anchors.rightMargin: DesktopTokens.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.text.length === 0
                    shortcut: "/"
                    keySize: DesktopTokens.px(20)
                    ink: DesktopTokens.textMuted
                }
            }

            DesktopButton {
                id: activeSessionButton
                objectName: "desktopHeaderResume"
                visible: ShellStore.resumableSession !== null && root.route !== "stream"
                x: bar.clusterLeft - DesktopTokens.px(10) - width
                width: bar.resumeWidth
                height: DesktopTokens.px(34)
                anchors.verticalCenter: parent.verticalCenter
                primary: true
                glyph: "desktop-play.svg"
                glyphSize: DesktopTokens.px(10)
                font.pixelSize: DesktopTokens.px(12)
                text: root.activeSessionPrompt()
                ToolTip.visible: hovered
                ToolTip.text: text
                ToolTip.delay: 700
                contentItem: Item {
                    DesktopGlyph {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: activeSessionButton.glyphSize
                        height: width
                        icon: "desktop-play.svg"
                    }
                    Text {
                        x: activeSessionButton.glyphSize + DesktopTokens.px(8)
                        width: Math.max(0, parent.width - x)
                        anchors.verticalCenter: parent.verticalCenter
                        text: activeSessionButton.text
                        elide: Text.ElideRight
                        color: Theme.focusText
                        font.family: DesktopTokens.bodyFont
                        font.pixelSize: DesktopTokens.px(12)
                        font.weight: Font.Bold
                    }
                }
                onClicked: ShellStore.resumeActiveSession()
            }

            AbstractButton {
                id: helpButton
                objectName: "desktopHeaderHelp"
                x: bar.clusterLeft
                width: bar.helpWidth
                height: width
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                Accessible.name: qsTr("Help")
                onClicked: AppController.showOverlay("guide-shortcuts")
                background: Rectangle {
                    radius: DesktopTokens.px(6)
                    color: helpButton.hovered || helpButton.activeFocus ? DesktopTokens.raised : "transparent"
                }
                contentItem: DesktopSettingsIcon {
                    anchors.centerIn: parent
                    width: DesktopTokens.px(19)
                    height: width
                    glyph: "help"
                    ink: DesktopTokens.textBody
                }
            }

            AbstractButton {
                id: accountChip
                objectName: "desktopHeaderAccount"
                x: bar.clusterLeft + bar.helpWidth + DesktopTokens.px(4)
                width: bar.chipWidth
                height: DesktopTokens.px(40)
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                Accessible.name: qsTr("Account: %1").arg(root.accountName())
                ToolTip.visible: hovered
                ToolTip.delay: 700
                ToolTip.text: accountChip.Accessible.name
                onClicked: root.routeRequested("settings-account")
                background: Rectangle {
                    radius: DesktopTokens.px(6)
                    color: accountChip.hovered || accountChip.activeFocus ? DesktopTokens.raised : "transparent"
                }
                contentItem: Row {
                    anchors.left: parent.left
                    anchors.leftMargin: DesktopTokens.px(2)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: DesktopTokens.px(8)
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: DesktopTokens.px(28)
                        height: width
                        radius: width / 2
                        color: DesktopTokens.raisedStrong
                        DesktopSettingsIcon {
                            anchors.centerIn: parent
                            width: DesktopTokens.px(18)
                            height: width
                            glyph: "user"
                            ink: DesktopTokens.text
                        }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        width: Math.max(0, accountChip.width - DesktopTokens.px(2) - DesktopTokens.px(28)
                            - DesktopTokens.px(8) - DesktopTokens.px(12) - DesktopTokens.px(8))
                        Text {
                            width: parent.width
                            text: root.accountName()
                            elide: Text.ElideRight
                            color: DesktopTokens.text
                            font.family: DesktopTokens.bodyFont
                            font.pixelSize: DesktopTokens.px(12.5)
                            font.weight: Font.DemiBold
                            font.capitalization: Font.MixedCase
                        }
                        Text {
                            width: parent.width
                            text: root.accountTier()
                            elide: Text.ElideRight
                            color: DesktopTokens.textMuted
                            font.family: DesktopTokens.bodyFont
                            font.pixelSize: DesktopTokens.px(11)
                        }
                    }
                    DesktopSettingsIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: DesktopTokens.px(12)
                        height: width
                        glyph: "chevronDown"
                        ink: DesktopTokens.textMuted
                    }
                }
            }
        }

        Item {
            id: contentHost
            objectName: "desktopContentHost"
            x: 0
            y: DesktopTokens.barHeight
            width: parent.width
            height: parent.height - DesktopTokens.barHeight
            clip: true
        }
    }

    Rectangle {
        id: drawerScrim
        // The bar keeps its own row: the drawer and its scrim start below it so
        // the menu button stays visible while the drawer is open.
        y: DesktopTokens.barHeight
        width: parent.width
        height: parent.height - DesktopTokens.barHeight
        color: Qt.rgba(0, 0, 0, 0.4)
        opacity: sidebar.overlayOpen ? 1 : 0
        visible: opacity > 0
        z: 30
        Behavior on opacity {
            NumberAnimation { duration: AppController.reducedMotion ? 0 : DesktopTokens.quickDuration }
        }
        TapHandler { onTapped: sidebar.closeOverlay() }
    }

    DesktopSidebar {
        id: sidebar
        z: 40
        y: DesktopTokens.barHeight
        height: root.height - DesktopTokens.barHeight
        currentRoute: root.route
        collapsed: !root.drawerOpen
        subtitle: root.subtitle
        onRouteRequested: route => {
            root.setDrawerOpen(false)
            root.routeRequested(route)
        }
        onConsoleModeRequested: {
            root.setDrawerOpen(false)
            root.consoleModeRequested()
        }
        onCollapseRequested: collapsed => root.setDrawerOpen(!collapsed)
        onCreateCollectionRequested: {
            sidebar.closeOverlay()
            collectionDialog.open()
        }
    }

    DesktopCollectionDialog {
        id: collectionDialog
        onCollectionOpened: collectionId => {
            ShellStore.activeCollectionId = collectionId
            root.routeRequested("library")
        }
    }

    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_K) {
            root.commandPaletteRequested()
            event.accepted = true
        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_B) {
            root.setDrawerOpen(!root.drawerOpen)
            event.accepted = true
        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Comma) {
            root.routeRequested("settings")
            event.accepted = true
        } else if (event.key === Qt.Key_Escape && root.drawerOpen) {
            root.setDrawerOpen(false)
            event.accepted = true
        } else if (event.key === Qt.Key_Slash && root.searchVisible) {
            search.forceActiveFocus()
            event.accepted = true
        }
    }
}
