import QtQuick 2.0
import Sailfish.Silica 1.0
import "../MediaStreamMode.js" as MediaStreamMode


Page {
    id: threadView
    height: parent.height
    width: parent.width
    clip: true

    property bool threadLoaded: false
    property string cursorId : "";
    property string newestCursor: "";
    property string oldestCursor: "";
    property string name:"";
    property string threadId;
    property var user;
    property int userLength:1;


    PageHeader {
        id: header
        title: name
    }

    ListModel {
        id: threadModel;
    }


    SilicaListView {
        id: grid
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        visible: threadLoaded

        width: parent.width
        height: parent.height
        clip: true

        model: threadModel

        PullDownMenu {
            id: topMenu;
            quickSelect: true
            visible: (newestCursor !== "")
            MenuItem {
                id: refreshMenu
                text: qsTr("Refresh")
                visible: true
                onClicked: {
                    instagram.getDirectThread(threadId,newestCursor);
                }
            }
        }

        PushUpMenu {
            id: bottomMenu
            visible: (oldestCursor !== "")
            quickSelect: true

            MenuItem {
                id: moreMenu
                text: qsTr("Load older")
                onClicked: {
                    instagram.getDirectThread(threadId,oldestCursor);
                }
            }
        }

        delegate:
            ThreadMessageItem {
                pic_url: getUser(model.user_id);
                isSelf: isSelfID(model.user_id);

            }

    }

    BusyIndicator {
        anchors.centerIn: grid
        running: threadLoaded == false
    }

    Component.onCompleted: {
        if(threadModel.count === 0)
        {
            threadLoaded = false;
            instagram.getDirectThread(threadId);
        }
    }

    Connections {
        target: instagram
        onDirectThreadDataReady: {
            var data = JSON.parse(answer);

            for(var j=0;j<data.thread.items.length;j++) {
                threadModel.append(data.thread.items[j]);
            }
            user = data.thread.users;
            userLength = data.thread.users.length;

            name = data.thread.thread_title;

            if(data.thread.has_newer){newestCursor = data.thread.newest_cursor;}
            if(data.thread.has_older){oldestCursor = data.thread.oldest_cursor;}
            threadLoaded = true;
        }
    }

    function getUser(id) {
        //console.log(id," - ",instagram.getUsernameId());
        if (""+id ===  ""+instagram.getUsernameId()){
            return instagram.getProfilePic();

        }
        else for(var i=0; i < user.length; i++) {
            if(""+user[i].pk === ""+id) return user[i].profile_pic_url;
        }
    }
    function isSelfID(id) {
        if( ""+id === ""+instagram.getUsernameId() ) {
            return true;
        }
        else return false;

    }
}
