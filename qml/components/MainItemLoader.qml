import QtQuick 2.0

Rectangle {
    id: image

    property bool autoVideoPlay: true
    property bool isSquared: false

    width: parent.width
    anchors{
        left: parent.left
        right: parent.right
    }

    color: "transparent"
    Rectangle{
        id: mainItemLoader
        anchors.fill: parent
        width: parent.width



        clip: true
        color: "transparent"

        Loader{
            id: mainLoader
            anchors.fill: parent
            width: parent.width

            clip: true

            property var item
        }

        Component.onCompleted: {
            item.autoVideoPlay = image.autoVideoPlay
            item.isSquared = image.isSquared

            mainLoader.item = item

            if(item.media_type === 1 || item.media_type === 2)
            {
                if(!item.isSquared)
                {
                    image.height = parent.width/item.image_versions2.candidates[0].width*item.image_versions2.candidates[0].height
                }

                if(item.media_type === 1)
                {
                    mainLoader.source = "LoaderImage.qml"
                }
                else
                {
                    mainLoader.source = "LoaderVideo.qml"
                }

            }
            else if(item.media_type === 8)
            {
                var first_image = item.carousel_media.get(0);
                if(!item.isSquared)
                {
                    image.height = parent.width/first_image.image_versions2.candidates[0].width*first_image.image_versions2.candidates[0].height
                }
                mainLoader.source = "LoaderCarusel.qml"
            }

            if(item.isSquared)
            {
                image.height = image.width
            }
        }
    }
}
