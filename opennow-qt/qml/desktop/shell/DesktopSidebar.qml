import QtQuick
import QtQuick.Controls
import QtQuick.Window
import OpenNOW

// Navigation drawer. It sits off-canvas until the top-bar menu button opens it,
// then slides over the page on its own scrim instead of reserving a rail.
FocusScope {
    id: root
    objectName: "desktopSidebar"
    property string currentRoute: "home"
    property string subtitle: ""
    property bool collapsed: true
    readonly property bool overlayOpen: !collapsed
    // 0 while the drawer is parked off-canvas and 1 once it is open. It is a
    // real value rather than a flag so fades can follow the slide.
    property real reveal: overlayOpen ? 1 : 0
    Behavior on reveal {
        NumberAnimation { duration: AppController.reducedMotion ? 0 : DesktopTokens.motionDuration; easing.type: Easing.OutCubic }
    }
    readonly property bool consoleModeOn: DesktopTokens.consoleModeOn(Window.window)
    readonly property bool consoleModePending: DesktopTokens.consoleModePending(Window.window)
    readonly property bool friendsAvailable: Boolean(ShellStore.socialCapabilities && ShellStore.socialCapabilities.friendsAvailable)
    signal routeRequested(string route)
    signal consoleModeRequested()
    signal collapseRequested(bool collapsed)
    signal createCollectionRequested()

    width: DesktopTokens.drawerWidth
    height: parent ? parent.height : 900
    x: overlayOpen ? 0 : -width
    // A closed drawer neither paints nor takes keyboard focus; the slide-out
    // still plays because x keeps animating while it is hidden.
    enabled: overlayOpen
    visible: x > -width + 0.5

    function closeOverlay() {
        if (!collapsed)
            collapseRequested(true)
    }

    function regionStatusText() {
        const selected = String(ShellStore.settings.region || "")
        if (selected === "")
            return qsTr("Automatic region")
        const regions = ShellStore.regions || []
        for (let i = 0; i < regions.length; ++i) {
            if (regions[i].name === selected || regions[i].url === selected) {
                const ping = ShellStore.regionPingResults ? ShellStore.regionPingResults[regions[i].url] : undefined
                const name = String(regions[i].name || selected)
                return ping === undefined || ping === null || ping === ""
                    ? name : qsTr("%1 · %2 ms").arg(name).arg(ping)
            }
        }
        return selected
    }

    Behavior on x {
        NumberAnimation { duration: AppController.reducedMotion ? 0 : DesktopTokens.motionDuration; easing.type: Easing.OutCubic }
    }

    readonly property var navItems: [
        { route: "home", icon: "desktop-nav-home.svg", name: qsTr("Home") },
        { route: "library", icon: "desktop-nav-library.svg", name: qsTr("Library") },
        { route: "store", icon: "desktop-nav-store.svg", name: qsTr("Store") },
        { route: "friends", icon: "desktop-nav-friends.svg", name: qsTr("Friends") },
        { route: "settings", icon: "desktop-nav-settings.svg", name: qsTr("Settings") }
    ]

    function liveMembershipTier() {
        // The login claim goes stale (e.g. upgrade after sign-in); the live
        // subscription is authoritative, the cached claim is the fallback.
        if (ShellStore.subscription && ShellStore.subscription.membershipTier)
            return DesktopTokens.displayCase(ShellStore.subscription.membershipTier)
        if (ShellStore.signedIn && ShellStore.authSession && ShellStore.authSession.user
                && ShellStore.authSession.user.membershipTier)
            return DesktopTokens.displayCase(ShellStore.authSession.user.membershipTier)
        return ShellStore.signedIn ? qsTr("Member") : qsTr("Not signed in")
    }

    function routeSelected(route) {
        if (route === "settings")
            return root.currentRoute.indexOf("settings") === 0
        if (route === "library")
            return root.currentRoute === "library" || root.currentRoute === "game-detail"
        return root.currentRoute === route
    }

    Rectangle {
        anchors.fill: parent
        color: DesktopTokens.drawer
        Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: DesktopTokens.edgeInk }
    }

    Item {
        anchors.fill: parent
        clip: true
        anchors.topMargin: DesktopTokens.px(12)
        anchors.leftMargin: DesktopTokens.px(10)
        anchors.rightMargin: DesktopTokens.px(10)
        anchors.bottomMargin: DesktopTokens.px(10)

        Column {
            id: topColumn
            width: parent.width
            spacing: DesktopTokens.px(10)

            Item {
                width: parent.width
                height: DesktopTokens.px(34)

                Image {
                    id: brandMark
                    width: DesktopTokens.px(38)
                    height: DesktopTokens.px(21)
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/qt/qml/OpenNOW/res/brand/opennow-mark.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: false
                    sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: brandMark.right
                    anchors.leftMargin: DesktopTokens.px(10)
                    text: qsTr("GeforceXYZ")
                    color: DesktopTokens.text
                    font.family: DesktopTokens.displayFont
                    font.pixelSize: DesktopTokens.px(16)
                    font.weight: Font.Bold
                    font.letterSpacing: -0.2
                }

                AbstractButton {
                    id: closeButton
                    objectName: "desktopDrawerClose"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: DesktopTokens.px(30)
                    height: width
                    hoverEnabled: true
                    Accessible.name: qsTr("Close navigation")
                    onClicked: root.closeOverlay()
                    background: Rectangle {
                        radius: DesktopTokens.px(6)
                        color: closeButton.hovered || closeButton.activeFocus ? DesktopTokens.raised : "transparent"
                    }
                    contentItem: DesktopSettingsIcon {
                        anchors.centerIn: parent
                        width: DesktopTokens.px(14)
                        height: width
                        glyph: "close"
                        ink: DesktopTokens.textBody
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.subtitle !== ""
                text: root.subtitle
                elide: Text.ElideRight
                color: DesktopTokens.textMuted
                font.family: DesktopTokens.bodyFont
                font.pixelSize: DesktopTokens.px(12)
            }

            Rectangle { width: parent.width; height: 1; color: DesktopTokens.seamSoft }
        }

        Flickable {
            id: railFlick
            anchors.top: topColumn.bottom
            anchors.topMargin: DesktopTokens.px(10)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: dock.top
            anchors.bottomMargin: DesktopTokens.px(8)
            clip: true
            contentWidth: width
            contentHeight: navColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: navColumn
                width: railFlick.width
                spacing: DesktopTokens.px(2)

                Repeater {
                    model: root.navItems
                    delegate: AbstractButton {
                        id: navButton
                        required property var modelData
                        width: navColumn.width
                        height: DesktopTokens.px(40)
                        hoverEnabled: true
                        readonly property bool selected: root.routeSelected(modelData.route)
                        Accessible.name: modelData.name
                        Accessible.checked: selected
                        onClicked: {
                            if (modelData.route === "library")
                                ShellStore.activeCollectionId = ""
                            root.routeRequested(modelData.route)
                        }
                        background: Rectangle {
                            radius: DesktopTokens.px(6)
                            color: navButton.selected ? DesktopTokens.raisedStrong
                                : navButton.hovered || navButton.activeFocus ? DesktopTokens.raised : "transparent"
                        }
                        contentItem: Item {
                            DesktopGlyph {
                                objectName: "sidebarIcon-" + navButton.modelData.route
                                x: DesktopTokens.px(12)
                                anchors.verticalCenter: parent.verticalCenter
                                width: DesktopTokens.px(18)
                                height: width
                                icon: navButton.modelData.icon
                                active: navButton.selected
                            }
                            Text {
                                x: DesktopTokens.px(44)
                                width: Math.max(0, parent.width - x - DesktopTokens.px(12))
                                anchors.verticalCenter: parent.verticalCenter
                                text: navButton.modelData.name
                                elide: Text.ElideRight
                                color: navButton.selected ? DesktopTokens.text : DesktopTokens.textBody
                                font.family: DesktopTokens.bodyFont
                                font.pixelSize: DesktopTokens.px(14)
                                font.weight: navButton.selected ? Font.DemiBold : Font.Normal
                            }
                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                visible: navButton.selected
                                width: DesktopTokens.accentBarWidth
                                height: DesktopTokens.px(18)
                                radius: width / 2
                                color: DesktopTokens.focus
                            }
                            Rectangle {
                                anchors.right: parent.right
                                anchors.rightMargin: DesktopTokens.px(12)
                                anchors.verticalCenter: parent.verticalCenter
                                visible: navButton.modelData.route === "friends" && !navButton.selected
                                width: DesktopTokens.px(6)
                                height: width
                                radius: width / 2
                                color: root.friendsAvailable ? DesktopTokens.mint : DesktopTokens.textFaint
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: DesktopTokens.px(40)

                    Rectangle {
                        x: DesktopTokens.px(4)
                        width: DesktopTokens.px(24)
                        height: 1
                        anchors.verticalCenter: parent.verticalCenter
                        color: DesktopTokens.seamSoft
                    }
                    Text {
                        x: DesktopTokens.px(44)
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("COLLECTIONS")
                        color: DesktopTokens.textFaint
                        font.family: DesktopTokens.monoFont
                        font.pixelSize: DesktopTokens.tinySize
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.9
                    }
                    AbstractButton {
                        id: createCollectionButton
                        objectName: "createCollectionButton"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: DesktopTokens.px(28)
                        height: width
                        enabled: !ShellStore.collectionsBusy
                        Accessible.name: qsTr("New collection")
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("New collection")
                        background: Rectangle {
                            radius: DesktopTokens.px(6)
                            color: createCollectionButton.hovered || createCollectionButton.activeFocus ? DesktopTokens.raised : "transparent"
                        }
                        contentItem: DesktopGlyph {
                            width: DesktopTokens.px(14)
                            height: width
                            anchors.centerIn: parent
                            icon: "desktop-plus.svg"
                        }
                        onClicked: root.createCollectionRequested()
                    }
                }

                Repeater {
                    model: ShellStore.gameCollections
                    delegate: AbstractButton {
                        id: collectionRow
                        required property var modelData
                        width: navColumn.width
                        height: DesktopTokens.px(36)
                        hoverEnabled: true
                        Accessible.name: modelData.name
                        onClicked: {
                            ShellStore.activeCollectionId = modelData.id
                            root.routeRequested("library")
                            root.closeOverlay()
                        }
                        background: Rectangle {
                            radius: DesktopTokens.px(6)
                            color: ShellStore.activeCollectionId === collectionRow.modelData.id
                                   && root.currentRoute === "library"
                                ? DesktopTokens.raisedStrong
                                : collectionRow.hovered || collectionRow.activeFocus ? DesktopTokens.raised : "transparent"
                        }
                        contentItem: Item {
                            DesktopGlyph {
                                objectName: "sidebarCollectionIcon-" + collectionRow.modelData.id
                                x: DesktopTokens.px(13)
                                anchors.verticalCenter: parent.verticalCenter
                                width: DesktopTokens.px(15)
                                height: width
                                icon: "desktop-nav-library.svg"
                            }
                            Text {
                                x: DesktopTokens.px(44)
                                width: Math.max(0, parent.width - x - DesktopTokens.px(44))
                                anchors.verticalCenter: parent.verticalCenter
                                text: collectionRow.modelData.name
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                color: collectionRow.hovered ? DesktopTokens.text : DesktopTokens.textBody
                                font.family: DesktopTokens.bodyFont
                                font.pixelSize: DesktopTokens.px(13)
                                font.weight: Font.Normal
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: DesktopTokens.px(12)
                                anchors.verticalCenter: parent.verticalCenter
                                text: collectionRow.modelData.gameIds.length
                                color: DesktopTokens.textFaint
                                font.family: DesktopTokens.monoFont
                                font.pixelSize: DesktopTokens.tinySize
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                Text {
                    x: DesktopTokens.px(44)
                    width: Math.max(0, parent.width - x - DesktopTokens.px(12))
                    visible: ShellStore.gameCollections.length === 0
                    text: qsTr("Create your first collection with +")
                    wrapMode: Text.WordWrap
                    color: DesktopTokens.textFaint
                    font.family: DesktopTokens.bodyFont
                    font.pixelSize: DesktopTokens.px(12)
                }
            }
        }

        Column {
            id: dock
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: DesktopTokens.px(4)

            Rectangle { width: parent.width; height: 1; color: DesktopTokens.seamSoft }

            Row {
                width: parent.width
                height: DesktopTokens.px(22)
                spacing: DesktopTokens.px(7)
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: DesktopTokens.px(6)
                    height: width
                    radius: width / 2
                    color: ShellStore.signedIn ? DesktopTokens.focus : DesktopTokens.textFaint
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, parent.width - DesktopTokens.px(13))
                    elide: Text.ElideRight
                    text: root.regionStatusText()
                    color: DesktopTokens.textMuted
                    font.family: DesktopTokens.bodyFont
                    font.pixelSize: DesktopTokens.px(11.5)
                }
            }

            AbstractButton {
                id: consoleModeButton
                width: parent.width
                height: DesktopTokens.px(40)
                enabled: !root.consoleModePending
                opacity: root.consoleModePending ? 0.7 : 1
                Accessible.name: qsTr("Console mode")
                Accessible.description: root.consoleModePending
                    ? qsTr("Switching surfaces")
                    : (root.consoleModeOn ? qsTr("Console mode is on") : qsTr("Console mode is off"))
                Behavior on opacity { NumberAnimation { duration: DesktopTokens.quickDuration } }
                hoverEnabled: true
                background: Rectangle {
                    radius: DesktopTokens.px(6)
                    color: consoleModeButton.hovered || consoleModeButton.activeFocus ? DesktopTokens.raised : "transparent"
                }
                contentItem: Item {
                    DesktopGlyph {
                        x: DesktopTokens.px(12)
                        anchors.verticalCenter: parent.verticalCenter
                        width: DesktopTokens.px(17)
                        height: width
                        icon: "desktop-gamepad.svg"
                    }
                    Column {
                        x: DesktopTokens.px(44)
                        width: Math.max(0, parent.width - x - DesktopTokens.px(52))
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.consoleModePending ? qsTr("Console mode…") : qsTr("Console mode")
                            color: DesktopTokens.text
                            font.family: DesktopTokens.bodyFont
                            font.pixelSize: DesktopTokens.px(13)
                            font.weight: Font.Normal
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.consoleModePending ? qsTr("SWITCHING…")
                                : root.consoleModeOn ? qsTr("CONSOLE ON") : qsTr("GAMEPAD READY")
                            color: DesktopTokens.textMuted
                            font.family: DesktopTokens.monoFont
                            font.pixelSize: DesktopTokens.tinySize
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.36
                        }
                    }
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: DesktopTokens.px(4)
                        anchors.verticalCenter: parent.verticalCenter
                        width: DesktopTokens.px(32)
                        height: DesktopTokens.px(18)
                        radius: width / 2
                        color: root.consoleModeOn ? DesktopTokens.focus : DesktopTokens.raisedStrong
                        Rectangle {
                            x: root.consoleModeOn ? parent.width - width - 2 : 2
                            y: 2
                            width: DesktopTokens.px(14)
                            height: width
                            radius: width / 2
                            color: root.consoleModeOn ? Theme.focusText : DesktopTokens.textMuted
                            Behavior on x { NumberAnimation { duration: DesktopTokens.quickDuration; easing.type: Easing.OutCubic } }
                        }
                    }
                }
                onClicked: root.consoleModeRequested()
            }

            AbstractButton {
                id: profileButton
                width: parent.width
                height: DesktopTokens.px(44)
                hoverEnabled: true
                Accessible.name: qsTr("Profile")
                background: Rectangle {
                    radius: DesktopTokens.px(6)
                    color: profileButton.hovered || profileButton.activeFocus ? DesktopTokens.raised : "transparent"
                }
                contentItem: Item {
                    Rectangle {
                        x: DesktopTokens.px(2)
                        anchors.verticalCenter: parent.verticalCenter
                        width: DesktopTokens.px(32)
                        height: width
                        radius: width / 2
                        color: DesktopTokens.raisedStrong
                        DesktopSettingsIcon {
                            anchors.centerIn: parent
                            width: DesktopTokens.px(20)
                            height: width
                            glyph: "user"
                            ink: DesktopTokens.text
                        }
                    }
                    Column {
                        x: DesktopTokens.px(44)
                        width: Math.max(0, parent.width - x - DesktopTokens.px(24))
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: ShellStore.signedIn && ShellStore.authSession.user
                                ? ShellStore.authSession.user.displayName
                                : qsTr("Guest")
                            color: DesktopTokens.text
                            font.family: DesktopTokens.bodyFont
                            font.pixelSize: DesktopTokens.px(13)
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.liveMembershipTier()
                            color: DesktopTokens.textMuted
                            font.family: DesktopTokens.bodyFont
                            font.pixelSize: DesktopTokens.px(11.5)
                        }
                    }
                }
                onClicked: root.routeRequested("settings-account")
            }
        }
    }
}
