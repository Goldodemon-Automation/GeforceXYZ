pragma Singleton
import QtQuick

QtObject {
    // ---------------------------------------------------------------------
    // Black UI · grey text · Gold Bright accent
    //
    // One palette, one metallic accent. Surfaces are black, text is a grey
    // ramp (off-white, mid grey, then the dark grey step for dim chrome), and
    // #FFD34D is the only chromatic ink in the system. Theme packs below are
    // tonal steps on the black-to-white axis; every one shares the accent.
    //
    // Pack ids are part of saved settings, so they stay stable while the
    // names, blurbs, and tones move to the new palette.
    // ---------------------------------------------------------------------
    readonly property string goldBright: "#FFD34D"
    readonly property string gold: "#C9A227"
    readonly property string goldDeep: "#8A6D1B"
    readonly property string goldInk: "#6B5410"
    // Grey ramp. #2E2E2E is the dark grey step: it carries dim chrome and the
    // light-mode ink, never body copy on black (it is 1.5:1 there).
    readonly property string greyDark: "#2E2E2E"
    readonly property string greyMid: "#8A8A8A"
    readonly property string greyFaint: "#5F5F5F"
    readonly property string inkSoft: "#EDEDED"

    readonly property var packs: [
        {id:"nocturne", name:"Obsidian", author:"OPENNOW", category:"Dark", detail:"BLACK / GOLD", bg:"#0D0D0D", lightBg:"#FFFFFF", mid:"#2A2A2A", accent:"#FFD34D", lightAccent:"#8A6D1B"},
        {id:"aurora", name:"Graphite", author:"OPENNOW", category:"Dark", detail:"GRAPHITE / GOLD", bg:"#141414", lightBg:"#FAFAFA", mid:"#303030", accent:"#FFD34D", lightAccent:"#8A6D1B"},
        {id:"kraft", name:"Carbon", author:"OPENNOW", category:"Dark", detail:"CARBON / BRASS", bg:"#1A1A1A", lightBg:"#F2F1EE", mid:"#3A362F", accent:"#FFD34D", lightAccent:"#8A6D1B"},
        {id:"phosphor", name:"Pure contrast", author:"OPENNOW", category:"High contrast", detail:"PURE BLACK / GOLD", bg:"#000000", lightBg:"#FFFFFF", mid:"#1F1F1F", accent:"#FFD34D", lightAccent:"#6B5410", darkAccent:"#FFD34D"},
        {id:"bone", name:"Bone", author:"OPENNOW", category:"Light", detail:"WARM WHITE / GOLD", bg:"#F2EEE5", darkBg:"#131211", mid:"#A69C88", accent:"#8A6D1B", darkAccent:"#FFD34D"},
        {id:"cobalt", name:"Pearl", author:"OPENNOW", category:"Light", detail:"COOL WHITE / GOLD", bg:"#F7F7F5", darkBg:"#101010", mid:"#ADADAA", accent:"#8A6D1B", darkAccent:"#FFD34D"},
        {id:"hibiscus", name:"Basalt", author:"OPENNOW", category:"Dark", detail:"BASALT / GOLD", bg:"#1F1F1F", lightBg:"#EDEDED", mid:"#3C3C3C", accent:"#FFD34D", lightAccent:"#8A6D1B"},
        {id:"chapel", name:"Gilt", author:"OPENNOW", category:"Dark", detail:"GILDED BLACK", bg:"#121110", lightBg:"#F3F1EC", mid:"#4A4030", accent:"#FFD34D", lightAccent:"#8A6D1B"}
    ]
    readonly property string mode: String(ShellStore.settings.appTheme || "auto")
    readonly property string themePack: ShellStore.previewThemePack !== ""
                                        ? ShellStore.previewThemePack
                                        : String(ShellStore.settings.themePack || "nocturne")
    readonly property var pack: packs.find(item => item.id === themePack) || packs[0]
    readonly property bool packLight: pack.category === "Light"
    readonly property bool systemLight: Qt.styleHints.colorScheme === Qt.Light
    readonly property bool lightMode: ShellStore.previewThemePack !== "" ? packLight
        : mode === "light" || (mode === "auto" && systemLight)
    readonly property bool translucent: Boolean(ShellStore.settings.translucentUI)
    readonly property string accent: String(ShellStore.settings.appAccentColor || "gold")
    readonly property color shell: lightMode ? (pack.lightBg || pack.bg) : (pack.darkBg || pack.bg)
    // Inverted surface: soft ink on black, dark grey on white.
    readonly property color face: lightMode ? greyDark : inkSoft
    readonly property color faceText: contrastText(face)
    // Artwork scrims and dark store-color fallbacks always need a light foreground,
    // independently of the shell's light/dark mode.
    readonly property color mediaForeground: "#FFFFFF"
    readonly property color mediaMuted: Qt.rgba(mediaForeground.r, mediaForeground.g, mediaForeground.b, 0.64)
    readonly property color mediaAccent: accentOverridden ? accentColor(accent, false) : (pack.darkAccent || pack.accent)
    readonly property color seam: lightMode ? Qt.rgba(0.18, 0.18, 0.18, 0.20) : Qt.rgba(1, 1, 1, 0.16)
    readonly property color label: lightMode ? greyDark : inkSoft
    readonly property color textMuted: lightMode ? greyFaint : greyMid
    // The dark grey step for dim chrome: dividers, inactive glyphs, disabled
    // states. It is never used for text on a black surface.
    readonly property color dimChrome: greyDark
    // Accent overrides stay inside the palette: the gold accent plus two
    // monochrome stand-ins, never a second hue beside it.
    readonly property var accentChoices: ["gold", "silver", "white"]
    function accentColor(value, forLightMode = lightMode) {
        const dark = {gold: goldBright, silver: "#C4C7CB", white: "#FFFFFF"}
        const light = {gold: goldDeep, silver: "#4A4E54", white: "#374151"}
        return (forLightMode ? light : dark)[value] || (forLightMode ? light.gold : dark.gold)
    }
    readonly property color customAccent: accentColor(accent)
    readonly property color packAccent: lightMode ? (pack.lightAccent || pack.accent) : (pack.darkAccent || pack.accent)
    readonly property bool accentOverridden: ShellStore.previewThemePack === "" && ShellStore.settings.themeAccentOverride === true
    readonly property color focus: accentOverridden ? customAccent : packAccent
    readonly property color focusText: contrastText(focus)
    // Semantic roles, all resolved inside the palette. "Connected" uses the
    // accent rather than a green dot so no green/red pair ever appears at once.
    readonly property color mint: lightMode ? goldDeep : goldBright
    readonly property color violet: lightMode ? greyFaint : greyMid
    readonly property color yellow: lightMode ? goldDeep : goldBright
    readonly property color coral: lightMode ? "#B3261E" : "#F87171"
    readonly property color glass: Qt.rgba(shell.r, shell.g, shell.b, translucent ? 0.52 : 0.72)
    readonly property color glassStrong: Qt.rgba(shell.r, shell.g, shell.b, translucent ? 0.74 : 0.94)
    // Store identities are a neutral ramp; the store mark, not a hue,
    // carries the brand.
    // Store marks keep their brand colours: they identify a shop, they are not
    // part of the black/gold surface palette.
    readonly property color cartSteam: "#26364A"
    readonly property color cartEpic: "#1B1B1F"
    readonly property color cartUbisoft: "#3A5BD9"
    readonly property color cartXbox: "#107C41"
    readonly property color cartGog: "#7B3FE4"
    readonly property color cartBattlenet: "#2E7CB8"

    function contrastText(background) {
        const linear = value => value <= 0.04045 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4)
        const luminance = linear(background.r) * 0.2126 + linear(background.g) * 0.7152 + linear(background.b) * 0.0722
        return (luminance + 0.05) / 0.0592 > 1.05 / (luminance + 0.05) ? "#0A0D14" : "#FFFFFF"
    }

    readonly property string displayFont: "Outfit"
    readonly property string bodyFont: "Inter"
    readonly property string monoFont: "Inter"

    readonly property int focusDuration: AppController.reducedMotion ? 0 : 140
    readonly property int enterDuration: AppController.reducedMotion ? 0 : 260
    readonly property int heroDuration: AppController.reducedMotion ? 0 : 200
    readonly property int overlayDuration: AppController.reducedMotion ? 0 : 180
    readonly property int panelDuration: AppController.reducedMotion ? 0 : 220
    readonly property var easeOut: [0.16, 1.0, 0.3, 1.0]
    readonly property var easeEmphasized: [0.2, 0.9, 0.1, 1.0]

    function unit(windowWidth, windowHeight) {
        return Math.min(windowWidth / 100, windowHeight / 56.25)
    }
}
