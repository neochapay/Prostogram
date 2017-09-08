import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../MediaStreamMode.js" as MediaStreamMode

import "../components"

Page {

    allowedOrientations:  Orientation.All


    property bool dataLoaded : false
    property bool loadingMore : false


    property int pageNr : 1
    id: tagsPage

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Search for tag")
        }

        SearchField {
            anchors.top: header.bottom
            id: searchField
            width: parent.width

            onTextChanged: {
                if(searchField.text == "")
                {
                    list.model = [];
                }
                timerSearchTags.restart();
            }
        }


        PullDownMenu {
            MenuItem {
                id: searchUser
                text: qsTr("Search user")
                visible: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UserSearchPage.qml"),{user: user});
                }
            }
            MenuItem {
                id: explore
                text: qsTr("Explore")
                visible: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ExplorePage.qml"),{user: user});
                }
            }
        }

        SilicaListView {
            id: list
            anchors.top: searchField.bottom
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            visible: dataLoaded

            clip: true

            delegate: FeedItem {item: modelData}

            VerticalScrollDecorator { }

        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false && searchField.text.trim() !== ""
        size: BusyIndicatorSize.Large
    }

    function searchTagsData() {
        instagram.tagFeed(searchField.text);
    }

    Connections{
        target: instagram
        onTagFeedDataReady:{
            var data  = JSON.parse(answer)
            list.model = data.ranked_items
            dataLoaded = true;
        }
    }


    Timer {
        id: timerSearchTags
        interval: 600
        running: false
        repeat: false
        onTriggered: searchTagsData()
    }

    Component.onCompleted: {
        refreshCallback = null
    }


}




