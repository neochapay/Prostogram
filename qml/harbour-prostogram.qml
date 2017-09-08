import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import org.nemomobile.dbus 2.0
import harbour.prostogram 1.0
import harbour.prostogram.cache 1.0

import "pages"
import "components"

import "Storage.js" as Storage
import "MediaStreamMode.js" as MediaStreamMode
import "Cover.js" as CoverCtl
import "FavManager.js" as FavManager

ApplicationWindow {
    id: app
    property var cachedFeeds : null
    property var cachedFeedsTime : null

    property var refreshCallback : null
    property bool refreshCallbackPending : false

    property var user
    property bool need_login : true

    signal coverRefreshButtonPress();

    allowedOrientations: Orientation.Portrait

    initialPage: getInitialPage()
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    DBusAdaptor {
        id: dbus

        service: 'org.prostogram.notify'
        iface: 'org.prostogram.notify'
        path: '/org/prostogram/notify'

        xml: '  <interface name="com.prostogram.notify">\n' +
             '    <method name="showPhoto">\n' +
             '      <arg name="mediaId" type="s" direction="in"/>\n' +
             '    </method>\n' +
             '  </interface>\n'

        function showNotifyPage() {
            var page = pageStack.find(function(page){
                return page.objectName === "notificationPage";
            })
            if(page)
            {
                pageStack.pop(page);
                pageStack.replace(Qt.resolvedUrl("pages/NotificationPage.qml"));
            }
            else
            {
                pageStack.push(Qt.resolvedUrl("pages/NotificationPage.qml"));
            }
            app.activate()
        }
    }

    Instagram{
        id: instagram
    }

    CacheImage{
        id: cache
    }

    NotificationStream{
        id: notifyStream
    }

    function getInitialPage() {
        loadFavTags()
        var username = Storage.get("username");
        var password = Storage.get("password")
        if (username === "" ||  password === "" || username === undefined || password === undefined || username === null || password === null ) {
            app.need_login = true;
        } else {
            instagram.setUsername(username);
            instagram.setPassword(password);
            instagram.login(true);
            app.need_login = false;
        }

        cache.clean();
        cache.init();

        return Qt.resolvedUrl(Qt.resolvedUrl("pages/CoverPage.qml"))
    }

    function refresh(){
       coverRefreshButtonPress();
    }

    property int streamPreviewColumnCount: 3;
    property int  streamPreviewRowCount : 2;

    property bool  startPageShowPopularFeed : true;
    property bool  feedsShowCaptions : false;
    property bool feedsShowUserDate : true;
    property bool feedsShowUserDateInline : true;


    Component.onCompleted: {
        init();
    }

    Connections{
        target: instagram
        onMediaInfoReady:{
            var out = JSON.parse(answer);
            pageStack.push(Qt.resolvedUrl("pages/MediaDetailPage.qml"),{item: out.items[0]})
        }
        onError:{
            console.log("Error: "+message)
        }
        onDoLogout:{
            pageStack.clear();
            pageStack.push(Qt.resolvedUrl(Qt.resolvedUrl("pages/CoverPage.qml")))
        }
    }

    function init() {
        streamPreviewColumnCount = Storage.get("streamPreviewColumnCount", 3);
        streamPreviewRowCount = Storage.get("streamPreviewRowCount", 4);
        startPageShowPopularFeed = parseInt(Storage.get("startPageShowPopularFeed", 1)) === 1;
        feedsShowCaptions = parseInt(Storage.get("feedsShowCaptions", 0)) === 1;
        feedsShowUserDate = parseInt(Storage.get("feedsShowUserDate", 1)) === 1;
        feedsShowUserDateInline = parseInt(Storage.get("feedsShowUserDateInline", 1)) === 1;
    }

    function setCover(coverMode, coverData) {
        CoverCtl.nextMode = coverMode
        CoverCtl.nextCoverData = coverData
        CoverCtl.nextChanged = true
    }

    function setCoverRefresh(coverMode, coverData,refreshMode, refreshTag) {
        CoverCtl.refrMode = refreshMode
        CoverCtl.refrTag = refreshTag
        CoverCtl.nextMode = coverMode
        CoverCtl.nextCoverData = coverData
        CoverCtl.nextChanged = true
    }

    function saveFavTags() {
        var favTagsList = FavManager.favTags.join(';')
        Storage.set("favtags", favTagsList)
    }

    function loadFavTags() {
        var favTagsList = Storage.get("favtags", "")
        FavManager.favTags = favTagsList===""|| favTagsList===null  ? [] : favTagsList.split(";")
        FavManager.favTag = Storage.get("favtag", "")
    }


    onApplicationActiveChanged: {
        if (applicationActive === true) {

            if(refreshCallback!==null && refreshCallbackPending) {
                refreshCallbackPending = false
                refreshCallback()
            }
        }
    }

}
