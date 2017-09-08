import QtQuick 2.0
import Sailfish.Silica 1.0

import "../Helper.js" as Helper
import "../CoverMode.js" as CoverMode
import "../Cover.js" as CoverCtl
import "../components"

CoverBackground {

    property bool active: status == Cover.Active

    property var currentCoverData

    property int currentMode: 1

    property int feedMediaSize : width/2

    property bool dataLoading: false

    onActiveChanged: refreshCover()

    function refreshCover() {
        if(CoverCtl.nextChanged == false)
            return

        currentCoverData = CoverCtl.nextCoverData
        currentMode = CoverCtl.nextMode
        CoverCtl.nextChanged = false
        if(currentMode == CoverMode.SHOW_FEED) loadFeedMediaData(currentCoverData)
    }


    //### Mode: AppIcon
    Column {
        visible: currentMode = CoverMode.SHOW_APPICON

        anchors.centerIn: parent
        width: parent.width
        spacing: Theme.paddingMedium

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "/usr/share/icons/hicolor/86x86/apps/harbour-prostogram.png"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Prostogram"
        }
    }

    //### Mode: Image
    Column {
        visible: currentMode == CoverMode.SHOW_IMAGE
        width: parent.width
        spacing: Theme.paddingSmall

        Image {
            anchors.topMargin: Theme.paddingMedium
            width: parent.width
            height: width
            fillMode: Image.PreserveAspectCrop
            source: currentCoverData !== undefined && currentCoverData.image !== undefined ? currentCoverData.image : ""
        }

        Label {
            text: currentCoverData !== undefined && currentCoverData.username !== undefined ? currentCoverData.username : ""
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
        }
    }

    //### Mode: Feed

    Grid {
        visible: currentMode == CoverMode.SHOW_FEED
        columns: 2
        anchors.left: parent.left
        anchors.right: parent.right

        Repeater {
            model: feedMediaModel
            delegate: Item {
                width: feedMediaSize
                height: feedMediaSize
                opacity: dataLoading? 0.3 : (index < 4 ? 1.0 : 0.6)
                SmallMediaElement{
                    mediaElement: model
                }
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered : refreshFeed()
        }
    }



    ListModel {
        id: feedMediaModel

    }

    function loadFeedMediaData(data) {
        if(data === undefined || data.data === undefined) {
            return;
        }
        feedMediaModel.clear()
        var coverElementsCount = data.data.length > 8 ? 8 : data.data.length;
        for(var i=0; i< coverElementsCount; i++) {
            feedMediaModel.append(data.data[i]);
        }
    }
    function refreshFeed() {
        app.refresh();
    }
}
