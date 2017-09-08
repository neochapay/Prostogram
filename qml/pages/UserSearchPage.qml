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
    id: userPage


    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Search users")
        }

        SearchField {
            anchors.top: header.bottom
            id: searchField
            width: parent.width

            onTextChanged: {
                mediaModel.clear();
                timerSearchUser.restart();
            }
        }


        SilicaListView {
            id: listView
            model: mediaModel
            anchors.top: searchField.bottom
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.topMargin: 75
            visible: dataLoaded

            delegate: UserListItem {
                visible: dataLoaded
                item: model
            }

            VerticalScrollDecorator { }

        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: dataLoaded == false && searchField.text.trim() !== ""
        size: BusyIndicatorSize.Large
    }

    function searchUserData() {
        instagram.userFeed(searchField.text);
    }

    Connections{
        target: instagram
        onUserFeedDataReady:{
            var data  = JSON.parse(answer)
            for(var i=0; i<data.users.length; i++) {
                mediaModel.append(data.users[i]);
            }
            dataLoaded = true;
        }
    }


    Timer {
        id: timerSearchUser
        interval: 600
        running: false
        repeat: false
        onTriggered: searchUserData()
    }

    ListModel {
        id: mediaModel
    }

    Component.onCompleted: {
        refreshCallback = null
    }


}




