import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    id: threadMessageItem

    property var item
    property string pic_url;
    property bool isSelf: false;
    property bool isText: model.item_type === "text" ? true : false;

    height: isText? 100 : parent.width * 0.792;
    width: parent.width

    Image {
        id: profilpicture



        anchors.left: isSelf ? undefined : parent.left
        anchors.right: isSelf ? parent.right : undefined

        anchors.top: parent.top
        height: parent.width * 0.185
        width: parent.width * 0.185
        source: pic_url
    }

    Label {
        //id:message
        visible: isText
        text: isText? model.text : ""
        anchors.right: isSelf ? profilpicture.left: undefined
        anchors.left: isSelf? undefined : profilpicture.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        width: parent.width-profilpicture.width - 10
        wrapMode: Text.Wrap
        textFormat: Text.StyledText
        color: Theme.primaryColor
    }

    Image {
        visible: !isText
        anchors.left: profilpicture.right
        anchors.leftMargin: Theme.paddingMedium

        width: parent.width - 100 - Theme.paddingMedium
        height: width

        source: isText? "" : model.media_share.image_versions2.candidates[0].url
    }

}
