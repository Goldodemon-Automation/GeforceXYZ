pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import OpenNOW

// Home: shelves of wide artwork with a section name and a See all action. The
// first shelf is your own library and the connected-store summary; the rest are
// the sections the storefront service reports (GFN Thursday, per-store rows,
// top sellers), so nothing here is a fixed list of games.
FocusScope {
    id: root
    objectName: "desktopHomeScreen"

    property bool active: true
    property int focusZone: 0
    property int focusIndex: 0
    signal routeRequested(string route)
    signal gameRequested(var game)

    // Most recently played library game, and the timestamp its "continue
    // playing" line is relative to. libraryGames is already sorted by
    // lastPlayed, so the first entry is the one to continue.
    property double lastPlayedNowMs: Date.now()
    readonly property var heroGame: root.libraryGames.length ? root.libraryGames[0] : null

    Timer {
        interval: 1000
        repeat: true
        running: root.active && root.visible && Qt.application.state === Qt.ApplicationActive
        triggeredOnStart: true
        onTriggered: root.lastPlayedNowMs = Date.now()
    }

    function heroMeta() {
        const game = root.heroGame
        if (!game)
            return qsTr("Sign in and sync your library to continue a game.")
        const last = DesktopTokens.relativeLastPlayed(game.lastPlayed, root.lastPlayedNowMs)
        const hours = game.hoursPlayed ? qsTr("%1 h played").arg(game.hoursPlayed) : ""
        if (last !== "" && hours !== "")
            return last + " · " + hours
        if (last !== "")
            return last
        if (hours !== "")
            return hours
        return qsTr("Ready to stream from your library")
    }

    anchors.fill: parent
    focus: active
    clip: true
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Games")

    readonly property int gap: DesktopTokens.shelfGap
    readonly property int innerWidth: Math.max(DesktopTokens.px(320), contentFlick.width - DesktopTokens.px(48))
    readonly property int columnCount: Math.max(3, Math.min(8,
        Math.floor((innerWidth + gap) / (DesktopTokens.px(210) + gap))))
    readonly property int tileWidth: Math.max(DesktopTokens.px(150),
        Math.floor((innerWidth - gap * (columnCount - 1)) / columnCount))
    readonly property int tileHeight: Math.round(tileWidth / DesktopTokens.shelfAspect)
    readonly property var accounts: ShellStore.gameAccounts || []
    readonly property int connectedAccounts: {
        let count = 0
        for (let i = 0; i < accounts.length; ++i) {
            if (accounts[i].isConnected === true || accounts[i].status === "connected")
                ++count
        }
        return count
    }
    readonly property var libraryGames: {
        const list = (ShellStore.catalogGames || []).slice()
        list.sort((left, right) => String(right.lastPlayed || "").localeCompare(String(left.lastPlayed || "")))
        return list
    }
    readonly property var shelves: root.buildShelves()
    readonly property var zones: root.buildZones()

    function takeGames(source, limit) {
        const list = source || []
        return list.slice(0, Math.max(0, limit))
    }

    function buildShelves() {
        const result = []
        result.push({
            id: "library",
            title: qsTr("My Library"),
            seeAll: qsTr("See all"),
            route: "library",
            games: root.takeGames(root.libraryGames, 48)
        })
        const panels = ShellStore.storePanels || []
        for (let p = 0; p < panels.length; ++p) {
            const sections = panels[p].sections || []
            for (let s = 0; s < sections.length; ++s) {
                const games = root.takeGames(sections[s].games || [], 48)
                if (games.length === 0)
                    continue
                result.push({
                    id: "panel-" + p + "-" + s,
                    title: String(sections[s].title || panels[p].title || qsTr("Featured")),
                    seeAll: qsTr("See all"),
                    route: "store",
                    games: games
                })
            }
        }
        if (result.length === 1) {
            const favourites = []
            for (let i = 0; i < root.libraryGames.length; ++i) {
                if (ShellStore.isFavorite(root.libraryGames[i]))
                    favourites.push(root.libraryGames[i])
            }
            if (favourites.length > 0)
                result.push({id: "favourites", title: qsTr("Favourites"), seeAll: qsTr("See all"),
                    route: "library", games: root.takeGames(favourites, 48)})
        }
        return result
    }

    function buildZones() {
        const zones = ["accounts"]
        for (let i = 0; i < root.shelves.length; ++i)
            zones.push(root.shelves[i].id)
        return zones
    }

    // One row model per shelf: the connected-store summary (first shelf only)
    // followed by the games that fit on the visible line.
    function shelfSlots(shelf, shelfIndex) {
        const slots = []
        const capacity = root.columnCount - (shelfIndex === 0 ? 1 : 0)
        if (shelfIndex === 0)
            slots.push({accounts: true})
        const games = root.takeGames(shelf.games, capacity)
        for (let i = 0; i < games.length; ++i)
            slots.push({game: games[i]})
        return slots
    }

    function slotsFor(shelfIndex) {
        const shelf = root.shelves[shelfIndex]
        return shelf ? root.shelfSlots(shelf, shelfIndex) : []
    }

    function setSelection(zone, index) {
        root.focusZone = Math.max(0, Math.min(root.zones.length - 1, zone))
        const count = root.focusZone === 0 ? 1 : Math.max(1, root.slotsFor(root.focusZone - 1).length)
        root.focusIndex = Math.max(0, Math.min(count - 1, index))
    }

    function moveHorizontal(delta) {
        const count = root.focusZone === 0 ? 1 : Math.max(1, root.slotsFor(root.focusZone - 1).length)
        root.setSelection(root.focusZone, Math.max(0, Math.min(count - 1, root.focusIndex + delta)))
    }

    function moveVertical(delta) {
        root.setSelection(root.focusZone + delta, root.focusZone === 0 && delta > 0
            ? Math.min(root.focusIndex, 8) : root.focusIndex)
    }

    function activateSelection() {
        if (root.focusZone === 0) {
            root.routeRequested("settings-stores")
            return
        }
        const slot = root.slotsFor(root.focusZone - 1)[root.focusIndex]
        if (slot && slot.game)
            root.gameRequested(slot.game)
    }

    function startHero() {
        const game = root.libraryGames.length ? root.libraryGames[0] : null
        if (!game)
            return
        ShellStore.selectedGame = game
        if (ShellStore.signedIn)
            ShellStore.launchSelectedGame(false)
        else
            AppController.navigate("sign-in")
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Left) {
            root.moveHorizontal(-1)
        } else if (event.key === Qt.Key_Right) {
            root.moveHorizontal(1)
        } else if (event.key === Qt.Key_Up) {
            root.moveVertical(-1)
        } else if (event.key === Qt.Key_Down) {
            root.moveVertical(1)
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.activateSelection()
        } else {
            return
        }
        event.accepted = true
    }

    Flickable {
        id: contentFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, shelvesColumn.implicitHeight + DesktopTokens.px(32))
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 5200
        maximumFlickVelocity: 2200
        Accessible.role: Accessible.Pane

        Column {
            id: shelvesColumn
            x: DesktopTokens.px(24)
            y: DesktopTokens.px(18)
            width: contentFlick.width - DesktopTokens.px(48)
            spacing: DesktopTokens.px(26)

            Repeater {
                model: root.shelves

                delegate: Item {
                    id: shelfBlock
                    required property int index
                    required property var modelData
                    readonly property bool activeShelf: root.focusZone === index + 1
                    // The first shelf carries the continue-playing line, so its
                    // header is one caption taller than the other shelves'.
                    readonly property bool showContinueMeta: index === 0
                    readonly property int continueMetaHeight: DesktopTokens.captionSize + DesktopTokens.px(4)
                    readonly property int headerHeight: DesktopTokens.shelfHeaderHeight
                        + (showContinueMeta ? continueMetaHeight : 0)
                    width: shelvesColumn.width
                    height: headerHeight + root.tileHeight

                    Text {
                        id: shelfTitle
                        anchors.left: parent.left
                        anchors.top: parent.top
                        text: shelfBlock.modelData.title
                        color: DesktopTokens.text
                        font.family: DesktopTokens.bodyFont
                        font.pixelSize: DesktopTokens.px(17)
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.1
                    }

                    AbstractButton {
                        id: seeAllButton
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: DesktopTokens.px(-2)
                        visible: shelfBlock.modelData.seeAll !== ""
                        width: implicitWidth
                        height: DesktopTokens.px(26)
                        hoverEnabled: true
                        Accessible.name: qsTr("See all %1").arg(shelfBlock.modelData.title)
                        onClicked: root.routeRequested(shelfBlock.modelData.route)
                        contentItem: Text {
                            text: shelfBlock.modelData.seeAll
                            color: seeAllButton.hovered || seeAllButton.activeFocus
                                ? DesktopTokens.text : DesktopTokens.textMuted
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
                                anchors.bottomMargin: DesktopTokens.px(4)
                                width: parent.width
                                height: 1
                                visible: seeAllButton.hovered || seeAllButton.activeFocus
                                color: DesktopTokens.textMuted
                            }
                        }
                    }

                    // Continue playing: last-played metadata for the most recent
                    // library game, which opens that game when clicked.
                    AbstractButton {
                        id: continuePlaying
                        objectName: "desktopHomeContinuePlaying"
                        visible: shelfBlock.showContinueMeta && root.heroGame !== null
                        anchors.left: parent.left
                        anchors.top: shelfTitle.bottom
                        anchors.topMargin: DesktopTokens.px(2)
                        height: shelfBlock.continueMetaHeight
                        width: Math.max(0, Math.min(parent.width - seeAllButton.width
                            - DesktopTokens.px(16), continuePlayingText.implicitWidth))
                        hoverEnabled: true
                        Accessible.name: root.heroMeta()
                        onClicked: root.startHero()
                        contentItem: Text {
                            id: continuePlayingText
                            text: root.heroMeta()
                            color: continuePlaying.hovered ? DesktopTokens.text
                                : DesktopTokens.textMuted
                            font.family: DesktopTokens.bodyFont
                            font.pixelSize: DesktopTokens.captionSize
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Item {}
                    }

                    Row {
                        y: shelfBlock.headerHeight
                        width: parent.width
                        spacing: root.gap

                        Repeater {
                            model: root.shelfSlots(shelfBlock.modelData, shelfBlock.index)

                            delegate: Item {
                                id: slot
                                required property var modelData
                                required property int index
                                width: root.tileWidth
                                height: root.tileHeight

                                // The first shelf opens with the connected-store
                                // summary, exactly like the client this layout
                                // follows. The count is live account data.
                                AbstractButton {
                                    id: accountsCard
                                    visible: slot.modelData.accounts === true
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    Accessible.name: accountsCard.label()
                                    onClicked: root.routeRequested("settings-stores")
                                    function label() {
                                        return root.accounts.length === 0
                                            ? qsTr("Connect your game stores")
                                            : qsTr("%1 of %2 accounts connected")
                                                .arg(root.connectedAccounts).arg(root.accounts.length)
                                    }
                                    background: Rectangle {
                                        radius: DesktopTokens.tileRadius
                                        color: accountsCard.hovered || accountsCard.activeFocus
                                            ? DesktopTokens.raisedStrong : DesktopTokens.raised
                                        border.width: 1
                                        border.color: root.focusZone === 0 && AppController.inputMode !== "pointer"
                                            ? DesktopTokens.focus : DesktopTokens.edgeInk
                                    }
                                    contentItem: Item {
                                        DesktopSettingsIcon {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.verticalCenterOffset: DesktopTokens.px(-14)
                                            width: DesktopTokens.px(22)
                                            height: width
                                            glyph: "link"
                                            ink: DesktopTokens.textBody
                                        }
                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.verticalCenter
                                            anchors.topMargin: DesktopTokens.px(6)
                                            width: Math.max(0, parent.width - DesktopTokens.px(20))
                                            horizontalAlignment: Text.AlignHCenter
                                            elide: Text.ElideRight
                                            text: accountsCard.label()
                                            color: DesktopTokens.text
                                            font.family: Theme.bodyFont
                                            font.pixelSize: DesktopTokens.px(13)
                                            font.weight: Font.Medium
                                        }
                                    }
                                }

                                DesktopStoreCard {
                                    visible: slot.modelData.accounts !== true
                                    game: slot.modelData.game
                                    showInfo: false
                                    artAspect: 1 / DesktopTokens.shelfAspect
                                    tileWidth: root.tileWidth
                                    badge: DesktopTokens.storeBadge(slot.modelData.game)
                                    selected: root.focusZone === shelfBlock.index + 1 && root.focusIndex === slot.index
                                        && AppController.inputMode !== "pointer"
                                    onPointed: root.setSelection(shelfBlock.index + 1, slot.index)
                                    onActivated: game => root.gameRequested(game)
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: DesktopTokens.px(96)
                visible: root.libraryGames.length === 0 && ShellStore.storePanels.length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    text: ShellStore.signedIn
                        ? qsTr("Sync a game store to fill your library.")
                        : qsTr("Sign in to see your games here.")
                    color: DesktopTokens.textMuted
                    font.family: Theme.bodyFont
                    font.pixelSize: DesktopTokens.px(13)
                }
                DesktopSettingsButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: DesktopTokens.px(34)
                    primary: true
                    text: ShellStore.signedIn ? qsTr("Open store") : qsTr("Sign in")
                    onClicked: root.routeRequested(ShellStore.signedIn ? "store" : "sign-in")
                }
            }
        }
    }

    Component.onCompleted: {
        root.focusZone = 0
        root.focusIndex = 0
        if (root.active)
            Qt.callLater(root.forceActiveFocus)
    }
}
