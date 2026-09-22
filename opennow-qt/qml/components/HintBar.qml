import QtQuick
import OpenNOW

GlassPanel {
    id: root
    Accessible.ignored: true
    property var hints: [
        { glyph: "Y", label: qsTr("Search") },
        { glyph: "VIEW", label: qsTr("Details") }
    ]
    implicitWidth: hintColumn.implicitWidth + 40
    implicitHeight: 84
    panelRadius: 18
    strong: true

    Column {
        id: hintColumn
        anchors.centerIn: parent
        spacing: 7
        Repeater {
            model: root.hints
            ControllerGlyph {
                required property var modelData
                glyph: modelData.glyph
                keyboard: Boolean(modelData.keyboard)
                label: modelData.label
            }
        }
    }
}
