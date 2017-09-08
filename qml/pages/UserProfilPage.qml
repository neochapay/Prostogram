import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "../components"
import "../Helper.js" as Helper
import "../MediaStreamMode.js" as MediaStreamMode


Page {


    allowedOrientations:  Orientation.All

    property var user
    property var recentMediaData

    property bool relationStatusLoaded : false
    property var relationStatus;

    property bool privateProfile : false;
    property bool recentMediaLoaded: false;

    property int recentMediaSize: (width - 2 * Theme.paddingMedium) / 3

    property bool errorAtUserMediaRequestOccurred : false

    property string rel_outgoing_status : "";
    property string rel_incoming_status : "";

    property bool isSelf: false;



    onStatusChanged: {
        if (status === PageStatus.Active) {
            if(app.user.pk === user.pk)
            {
                isSelf = true;
                followingMenuItem.visible = true
                followersMenuItem.visible = true
                followMenuItem.visible = false
                unFollowMenuItem.visible = false
            }
            else
            {
                isSelf = false;
            }
        }
    }

    SilicaFlickable {
        id: allView
        anchors.fill: parent
        contentHeight: column.height + header.height + 10
        contentWidth: parent.width

        PageHeader {
            id: header
            title: user.username
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column
            spacing: Theme.paddingSmall

            Item {
                width: parent.width
                height: 150
                Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity: 0.1
                }
                UserDetailBlock{
                }
            }

            Label {
                id: incomingRelLabel
                text: getOutgoingText()
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.primaryColor
                truncationMode: TruncationMode.Fade
                visible: text!==""
                function getOutgoingText() {
                    if(!relationStatus)
                    {
                        return "";
                    }
                    if(relationStatus.following)
                        return qsTr("You follow %1").arg(user.username);
                    if(relationStatus.outgoing_request)
                        return qsTr("You requested to follow %1").arg(user.username);
                    return ""
                }
            }

            Label {
                text: getIncomingText()
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.primaryColor
                truncationMode: TruncationMode.Fade
                visible: text!==""

                function getIncomingText() {
                    if(!relationStatus)
                    {
                        return "";
                    }

                    if(relationStatus.followed_by)
                        return qsTr("%1 follows you").arg(user.username);
                    if(relationStatus.incoming_request)
                        return qsTr("%1 requested to follow you").arg(user.username);
                    if(relationStatus.blocking)
                        return qsTr("You blocked %1").arg(user.username)
                    return ""
                }
            }


            Label {
                text: user.full_name
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.highlightColor
                truncationMode: TruncationMode.Fade
                font.bold: true


            }
            Label {
                text: user.bio !== undefined ? user.bio : ""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.highlightColor
                visible: text!==""
                wrapMode: Text.Wrap

            }

            Label {
                text: user.website !== undefined ? user.website :""
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.secondaryColor
                visible: text!==""
                truncationMode: TruncationMode.Fade
            }


            Label {
                id: privatelabel
                text: qsTr("This profile is private.")
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                color: Theme.highlightColor
                visible: false
            }


            BusyIndicator {
                running: visible
                visible: !recentMediaLoaded
                anchors.horizontalCenter: parent.horizontalCenter
            }


            Item {
                id:gridHeader

                height: Theme.itemSizeMedium
                width: parent.width
                visible: !privatelabel.visible


                Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity : mouseAreaHeader.pressed ? 0.3 : 0
                }

                Image {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    source:  "image://theme/icon-m-right"
                }

                Label {
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.primaryColor

                    text: user.username
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: icon.left
                    anchors.rightMargin: Theme.paddingMedium
                }

                MouseArea {
                    id: mouseAreaHeader
                    anchors.fill: parent
                    onClicked: pageStack.push(Qt.resolvedUrl("MediaStreamPage.qml"),{mode : MediaStreamMode.USER_MODE, streamData: recentMediaData,tag: user.pk, streamTitle: user.username})
                }
            }


            GridView {
                width: parent.width
                height: allView.height
                cellWidth: width/3
                cellHeight: cellWidth

                clip: true

                anchors{
                    left: parent.left
                    right: parent.right
                }

                model: recentMediaModel

                delegate:Item{
                    property var item: model
                    width: parent.width/3
                    height: width

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

            }
        }


        PullDownMenu {
            MenuItem {
                id: logoutItem
                text: qsTr("Logout")
                visible: isSelf
                onClicked: {
                    instagram.logout();
                }
            }

            MenuItem {
                id: followersMenuItem
                visible: isSelf
                text:  qsTr("Followers")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UserListPage.qml"),{pageTitle:qsTr("Followers"), userId: user.pk});
                }
            }

            MenuItem {
                id: followingMenuItem
                visible: isSelf
                text:  qsTr("Following")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("UserListPage.qml"),{pageTitle:qsTr("Following"), userId: user.pk });
                }
            }

            MenuItem {
                id: unFollowMenuItem
                text:  qsTr("Unfollow %1").arg(user.username)
                visible: !relationStatus.following && !isSelf
                onClicked: {
                    instagram.unfollow(user.pk);
                }
            }

            MenuItem {
                id: followMenuItem
                text: qsTr("Follow %1").arg(user.username)
                visible: !relationStatus.following && !isSelf
                onClicked: {
                    instagram.follow(user.pk);
                }
            }
        }
    }

    ListModel {
        id: recentMediaModel
    }


    Component.onCompleted: {
        instagram.getUsernameFeed(user.pk)
        instagram.getUsernameInfo(user.pk)

        refreshCallback = null
        if(app.user.pk === user.pk)
        {
            isSelf = true;
        }
        else
        {
            isSelf = false;
            instagram.userFriendship(user.pk);
        }
    }


    function reloadFinished(data) {
        if(data.meta.code===200) {
            user = data.data;
        } else {
            privateProfile = true;
        }
    }

    Connections{
        target: instagram
        onUserTimeLineDataReady:{
            //print(answer);
            var data = JSON.parse(answer);
            if(data === undefined || data.items === undefined) {
                recentMediaLoaded=true;
                return;
            }
            recentMediaData = data
            for(var i=0; i<data.items.length; i++) {
                recentMediaModel.append(data.items[i]);
            }
            recentMediaLoaded=true;
        }
    }

    Connections{
        target: instagram
        onUsernameDataReady:{
            var out = JSON.parse(answer);
            user = out.user
        }
    }

    Connections{
        target: instagram
        onUserFriendshipDataReady:{
            relationStatusLoaded = true;
            relationStatus = JSON.parse(answer)
            if(!isSelf)
            {
                followMenuItem.visible = !relationStatus.following
                unFollowMenuItem.visible = relationStatus.following
            }
            else
            {
                followMenuItem.visible = false
                unFollowMenuItem.visible = false
            }

            if(relationStatus.is_private)
            {
                privatelabel.visible = true
            }
        }
    }
}
