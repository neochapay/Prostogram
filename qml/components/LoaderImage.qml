import QtQuick 2.0
import harbour.prostogram.cache 1.0

Image {


    CacheImage {
        id:cache
    }

    id: mainImage

    width: parent.width
    height: parent.height
    visible: true
    fillMode: Image.PreserveAspectFit
    onVisibleChanged: {
        if (!visible){
        source: ""
        }
    }
    source: cache.getFromCache(item.image_versions2.candidates[0].url)
    //source: item.image_versions2.candidates[0].url
}
