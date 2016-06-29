#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtGui/QGuiApplication>
#include <QQmlContext>
#include <QQuickView>
#include <QtQml>
#include <QTranslator>

#include "api/instagram.h"
#include "models/folderlistmodel/qquickfolderlistmodel.h"

int main(int argc, char *argv[])
{
   QGuiApplication* app = SailfishApp::application(argc, argv);
   QString translationPath(SailfishApp::pathTo("translations").toLocalFile());

   QTranslator engineeringEnglish;
   engineeringEnglish.load("prostogram", translationPath);
   qApp->installTranslator(&engineeringEnglish);

   QTranslator translator;
   translator.load(QLocale(), "prostogram", "_", translationPath);
   qApp->installTranslator(&translator);

   QScopedPointer <QQuickView> view(SailfishApp::createView());
   app->setApplicationName("harbour-prostogram");
   app->setOrganizationDomain("harbour-prostogram");
   app->setOrganizationName("harbour-prostogram");

   view->setTitle("Prostogram");

   view->rootContext()->setContextProperty("Home",QDir::homePath());

   qmlRegisterType<Instagram>("harbour.prostogram",1,0,"Instagram");
   qmlRegisterType<QQuickFolderListModel>("harbour.prostogram.folderlistmodel",1,0,"FolderListModel");

   QUrl pageSource = SailfishApp::pathTo("qml/harbour-prostogram.qml");
   view->setSource(pageSource);


   view->showFullScreen();

   return app->exec();
}
