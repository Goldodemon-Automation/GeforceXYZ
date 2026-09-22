pragma Singleton
import QtQuick
import OpenNOW

QtObject {
    id: tokens

    function relativeLastPlayed(raw, nowMs) {
        const timestamp = Date.parse(String(raw || ""))
        if (isNaN(timestamp))
            return ""
        const seconds = Math.max(0, Math.floor((nowMs - timestamp) / 1000))
        if (seconds < 1)
            return qsTr("Just now")
        if (seconds < 60)
            return seconds === 1 ? qsTr("1 second ago") : qsTr("%1 seconds ago").arg(seconds)
        const minutes = Math.floor(seconds / 60)
        if (minutes < 60)
            return minutes === 1 ? qsTr("1 minute ago") : qsTr("%1 minutes ago").arg(minutes)
        const hours = Math.floor(minutes / 60)
        if (hours < 24)
            return hours === 1 ? qsTr("1 hour ago") : qsTr("%1 hours ago").arg(hours)
        const days = Math.floor(hours / 24)
        return days === 1 ? qsTr("1 day ago") : qsTr("%1 days ago").arg(days)
    }

    readonly property color shell: Theme.shell
    readonly property color rail: Qt.rgba(Theme.shell.r, Theme.shell.g, Theme.shell.b, 0.90)
    readonly property color topBar: Qt.rgba(Theme.shell.r, Theme.shell.g, Theme.shell.b, 0.66)
    readonly property color statusBar: Qt.rgba(Theme.shell.r, Theme.shell.g, Theme.shell.b, 0.78)
    readonly property color surface: Theme.glass
    // Neutral raise steps: no hue, just a lighter or darker step of the base.
    readonly property color raised: Theme.lightMode ? Qt.rgba(0.18, 0.18, 0.18, 0.08) : "#14FFFFFF"
    readonly property color raisedStrong: Theme.lightMode ? Qt.rgba(0.18, 0.18, 0.18, 0.13) : "#1FFFFFFF"
    readonly property color seam: Theme.seam
    readonly property color seamSoft: Theme.lightMode ? Qt.rgba(0.18, 0.18, 0.18, 0.07) : "#0FFFFFFF"
    // Grey text ramp on a black UI: off-white for primary copy, mid grey for
    // secondary, a darker grey step for captions. Dark grey (#2E2E2E) itself is
    // chrome-only — on black it is 1.5:1, so it never carries text.
    readonly property color text: Theme.label
    readonly property color textHigh: Theme.label
    readonly property color textBody: Theme.textMuted
    readonly property color textMuted: Theme.textMuted
    readonly property color textFaint: Theme.lightMode ? Theme.greyMid : Theme.greyFaint
    readonly property color divider: Theme.dimChrome
    readonly property color focus: Theme.focus
    // Black UI · grey text · gold-bright accent: status colours are tonal, not
    // chromatic, so one accent reads everywhere and no red/green pair appears.
    readonly property color gold: Theme.lightMode ? Theme.goldDeep : Theme.goldBright
    readonly property color goldBright: Theme.lightMode ? Theme.gold : Theme.goldBright
    readonly property color goldEdge: Qt.rgba(Theme.focus.r, Theme.focus.g, Theme.focus.b, 0.42)
    readonly property color goldWash: Qt.rgba(Theme.focus.r, Theme.focus.g, Theme.focus.b, 0.10)
    readonly property color green: Theme.lightMode ? Theme.goldDeep : Theme.gold
    readonly property color mint: Theme.lightMode ? Theme.goldDeep : Theme.goldBright
    readonly property color amber: Theme.lightMode ? Theme.goldDeep : Theme.goldBright
    readonly property color ledAmber: Theme.lightMode ? Theme.goldDeep : Theme.goldBright
    readonly property color danger: Theme.coral
    readonly property string displayFont: Theme.displayFont
    readonly property string bodyFont: Theme.bodyFont
    readonly property string monoFont: Theme.monoFont
    property real uiScale: 1
    // Type ramp. Every desktop font size must come from here so text stays
    // proportionate on any display size; raw pixelSize literals drift.
    readonly property int titleSize: px(28)
    readonly property int headingSize: px(18)
    readonly property int bodySize: px(15)
    readonly property int captionSize: px(13)
    readonly property int monoSize: px(12)
    readonly property int smallSize: px(11)
    readonly property int microSize: px(10)
    readonly property int tinySize: px(9)
    // Geometry ramp. Hairline seams, generous radii, and one rhythm for
    // padding keep the black surfaces reading as a single material.
    readonly property int radiusPanel: px(20)
    readonly property int radiusCard: px(14)
    readonly property int radiusControl: px(10)
    readonly property int radiusPill: px(999)
    readonly property int hairline: 1
    readonly property int spaceXs: px(6)
    readonly property int spaceSm: px(10)
    readonly property int spaceMd: px(16)
    readonly property int spaceLg: px(24)
    readonly property int spaceXl: px(36)
    readonly property int railWidth: px(232)
    readonly property int railCollapsedWidth: px(72)
    readonly property int topBarHeight: px(64)
    readonly property int statusBarHeight: px(52)
    readonly property int rowHeight: px(76)
    readonly property int controlHeight: px(38)
    readonly property int posterWidth: px(112)
    readonly property int posterHeight: px(168)
    readonly property int libraryCellWidth: px(146)
    readonly property int libraryCellHeight: px(214)
    readonly property int libraryArtWidth: px(132)
    readonly property int libraryArtHeight: px(198)
    property FontMetrics storeTitleMetrics: FontMetrics {
        font.family: Theme.bodyFont
        font.pixelSize: tokens.monoSize
        font.weight: Font.Bold
    }
    readonly property int storeCardInfoHeight: px(8) + Math.ceil(storeTitleMetrics.height) * 2 + px(4) + px(17) + px(4)
    readonly property int quickDuration: AppController.reducedMotion ? 0 : 120
    readonly property int motionDuration: AppController.reducedMotion ? 0 : 220
    readonly property int revealDuration: AppController.reducedMotion ? 0 : 320

    // ---------------------------------------------------------------------
    // GeForce NOW-style desktop chrome
    //
    // The shell is a full-width top bar over flat content: navigation lives in
    // a drawer, Settings uses a plain topic list with one accent bar, and
    // shelves are wide artwork tiles. These tokens keep that geometry and the
    // two extra surface steps in one place.
    // ---------------------------------------------------------------------
    function lift(colorValue, amount) {
        return Qt.rgba(Math.min(1, colorValue.r + amount), Math.min(1, colorValue.g + amount),
                        Math.min(1, colorValue.b + amount), colorValue.a)
    }
    // Bar and drawer sit one tonal step above the page so the strip reads as
    // chrome without an outline.
    readonly property color bar: Theme.lightMode ? Qt.darker(Theme.shell, 1.05) : lift(Theme.shell, 0.055)
    readonly property color drawer: Theme.lightMode ? Qt.darker(Theme.shell, 1.03) : lift(Theme.shell, 0.035)
    readonly property color panelTint: Theme.lightMode ? Qt.rgba(0, 0, 0, 0.04) : lift(Theme.shell, 0.02)
    // Hairline ink for borders between flat surfaces (the int above is a width).
    readonly property color edgeInk: Theme.lightMode ? Qt.rgba(0, 0, 0, 0.16) : "#1FFFFFFF"
    readonly property color tileFallback: Theme.lightMode ? "#E4E4E4" : "#1E1E1E"
    readonly property int barHeight: px(52)
    readonly property int drawerWidth: px(264)
    readonly property int navWidth: px(200)
    readonly property int navItemHeight: px(44)
    readonly property int readingWidth: px(760)
    readonly property int accentBarWidth: px(3)
    readonly property int tileRadius: px(6)
    // Shelf tiles are wider than the 16:9 capsule art they crop.
    readonly property real shelfAspect: 1.94
    readonly property int shelfGap: px(16)
    readonly property int shelfHeaderHeight: px(34)
    readonly property int settingsRowHeight: px(56)

    // "99h 50m" — hours that roll over into minutes, never a raw decimal.
    function durationLabel(hours) {
        const totalMinutes = Math.max(0, Math.round((Number(hours) || 0) * 60))
        const wholeHours = Math.floor(totalMinutes / 60)
        const minutes = totalMinutes % 60
        return minutes > 0 ? wholeHours + "h " + minutes + "m" : wholeHours + "h"
    }

    // Shelf badge: a discount when the catalog reports one. Nothing else is
    // invented, so a tile without an offer simply has no badge.
    function storeBadge(game) {
        if (!game)
            return ""
        if (game.storeDiscount !== undefined && game.storeDiscount !== null)
            return String(game.storeDiscount)
        if (game.discount !== undefined && game.discount !== null)
            return String(game.discount)
        return ""
    }

    function relativeMs(timestampMs, nowMs) {
        const value = Number(timestampMs)
        if (!Number.isFinite(value) || value <= 0)
            return ""
        return relativeLastPlayed(new Date(value).toISOString(), nowMs)
    }

    // Membership tiers arrive as ids ("PERFORMANCE"); copy reads better in
    // sentence case without touching the value that settings compare against.
    function displayCase(value) {
        const text = String(value || "")
        return text.length === 0 ? text : text.charAt(0).toUpperCase() + text.slice(1).toLowerCase()
    }
    readonly property real cardHoverScale: 1.02
    readonly property int cardOutlinePad: 2
    readonly property color cardOutlineIdle: Theme.seam
    readonly property color cardOutlineFocus: Theme.focus

    function px(value) {
        return Math.max(1, Math.round(Number(value) * uiScale))
    }

    function scaleForWindow(width, height) {
        // Qt already accounts for display DPI. Keep logical text readable;
        // use reflow, not aggressive downscaling, for smaller windows.
        return Math.max(0.95, Math.min(1.15, Math.min(width / 1440, height / 900)))
    }

    function storeKey(value) {
        const key = String(value || "").toLowerCase()
        if (key.indexOf("steam") >= 0) return "steam"
        if (key.indexOf("epic") >= 0) return "epic"
        if (key.indexOf("ubisoft") >= 0 || key.indexOf("uplay") >= 0) return "ubisoft"
        if (key.indexOf("battle") >= 0) return "battlenet"
        if (key.indexOf("xbox") >= 0) return "xbox"
        if (key.indexOf("gog") >= 0) return "gog"
        if (key.indexOf("gaijin") >= 0) return "gaijin"
        if (key === "nvidia") return "nvidia"
        if (key === "ea" || key === "ea_app" || key === "origin") return "ea"
        return ""
    }
    function storeIconUrl(value) {
        const key = storeKey(value)
        return key ? "qrc:/qt/qml/OpenNOW/res/icons/store-" + key + ".svg" : ""
    }
    function storeLabel(value) {
        const labels = {steam:"Steam", epic:"Epic Games", ubisoft:"Ubisoft Connect", battlenet:"Battle.net",
            xbox:"Xbox", gog:"GOG", gaijin:"Gaijin", ea:"EA app", nvidia:"NVIDIA"}
        return labels[storeKey(value)] || (String(value).toUpperCase() === "NONE" ? qsTr("Direct launch") : String(value))
    }
    function genreLabel(value) {
        return String(value).toLowerCase().replace(/_/g, " ").replace(/\b\w/g, letter => letter.toUpperCase())
    }

    function artworkUrl(game, preferHero) {
        if (!game)
            return ""
        const raw = preferHero
            ? String(game.heroImageUrl || game.imageUrl || game.screenshotUrl || game.boxArtUrl || "")
            : String(game.imageUrl || game.heroImageUrl || game.screenshotUrl || game.boxArtUrl || "")
        return decodeArtworkUrl(raw)
    }

    function decodeArtworkUrl(url) {
        return String(url || "").split(";f=webp").join(";f=jpg")
    }

    function consoleModeOn(win) {
        return win
            ? Boolean(win.forceConsole || win.desktopSurfaceActive === false)
            : ShellStore.settings.launchInConsoleMode === true
    }
    function consoleModeTargetOn(win) {
        return win
            ? !Boolean(win.targetDesktopSurface)
            : ShellStore.settings.launchInConsoleMode === true
    }
    function consoleModePending(win) {
        return ShellStore.consoleSurfaceRequestId !== "" || Boolean(win
            && win.targetDesktopSurface !== undefined
            && win.targetDesktopSurface !== win.desktopSurfaceActive)
    }
}
