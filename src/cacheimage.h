#ifndef CACHEIMAGE_H
#define CACHEIMAGE_H

#include <QObject>
#include <QStandardPaths>
#include <QUrl>
#include <QFile>
#include <QDir>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QEventLoop>

class CacheImage : public QObject
{
    Q_OBJECT
public:
    explicit CacheImage(QObject *parent = 0);
    Q_INVOKABLE void init();
    Q_INVOKABLE QString getFromCache(const QString &str);
    Q_INVOKABLE void clean();
    Q_INVOKABLE void requestImage(const QUrl &url);

    const QString cacheLocation = "/home/nemo/.cache/harbour-prostogram/cache";

signals:
    void finished();

public slots:
    void downloadFinished();
    void downloadReadyRead();

private:
    QNetworkAccessManager manager;
    QNetworkReply *currentDownload;
    QFile output;
    bool downloaded=false;
};

#endif // CACHEIMAGE_H
