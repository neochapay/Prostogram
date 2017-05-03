import QtQuick 2.0

Rectangle {
    id: images
    property var item

    color: "transparent"

    MainItemLoader{
        id: mainLoader
        anchors.fill: parent
        width: parent.width

        clip: true

        autoVideoPlay: false
        isSquared: true
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: {
            pageStack.push(Qt.resolvedUrl("../pages/MediaDetailPage.qml"),{item:item});
        }
    }
}
