import QtQuick
import QtQuick.Controls
import OpenNOW

GlassPanel {
    id: root
    property string currentRoute: "home"
    signal routeRequested(string route)
    implicitWidth: 620
    implicitHeight: 68
    panelRadius: 18
    strong: true

    readonly property var destinations: [
        { route: "home", icon: "nav-home.svg", label: "Home" },
        { route: "library", icon: "nav-library.svg", label: "Library" },
        { route: "store", icon: "nav-controller.svg", label: "Store" },
        { route: "friends", icon: "nav-friends.svg", label: "Friends" },
        { route: "settings", icon: "nav-settings.svg", label: "Settings" },
        { route: "computer", icon: "nav-computer.svg", label: qsTr("Computer mode") }
    ]

    function selected(route) {
        if (route === "settings")
            return root.currentRoute.indexOf("settings") === 0
        return root.currentRoute === route
    }

    Row {
        anchors.centerIn: parent
        spacing: 0

        ControllerGlyph {
            anchors.verticalCenter: parent.verticalCenter
            glyph: "LB"
            label: ""
            glyphSize: 22
            glyphColor: Theme.textMuted
        }

        Repeater {
            model: root.destinations
            ItemDelegate {
                id: destination
                required property var modelData
                width: 86
                height: 41
                padding: 0
                focusPolicy: Qt.StrongFocus
                readonly property bool active: root.selected(destination.modelData.route)
                Accessible.name: I18n.source(destination.modelData.label, I18n.revision)
                Accessible.role: Accessible.Button
                onClicked: root.routeRequested(modelData.route)
                Keys.onReturnPressed: clicked()

                background: Item {}
                contentItem: Column {
                    spacing: 5
                    anchors.centerIn: parent
                    // Inactive destinations recede to muted ink so the single
                    // gold underline carries "you are here".
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 32
                        height: 32
                        opacity: destination.active || destination.activeFocus ? 1 : 0.62
                        source: destination.modelData.icon === "nav-controller.svg"
                            ? InputPromptIcons.sourceFor("controller", Theme.face)
                            : "qrc:/qt/qml/OpenNOW/res/icons/" + destination.modelData.icon
                        sourceSize: Qt.size(32, 32)
                        fillMode: Image.PreserveAspectFit
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 32
                        height: 2
                        radius: 1
                        color: destination.active ? Theme.focus : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.focusDuration } }
                    }
                }
            }
        }

        ControllerGlyph {
            anchors.verticalCenter: parent.verticalCenter
            glyph: "RB"
            label: ""
            glyphSize: 22
            glyphColor: Theme.textMuted
        }
    }
}
