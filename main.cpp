#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "DatabaseManager.h"
#include "TodoListModel.h"

int main(int argc, char *argv[])
{
    // 开启高分屏支持，这是现代桌面应用的标配
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    // 1. 初始化 SQLite 数据库
    if (!DatabaseManager::instance().initDatabase()) {
        qFatal("Failed to initialize database!");
        return -1;
    }

    // 2. 实例化 Model 并加载数据
    TodoListModel todoModel;
    todoModel.loadTasks();

    // 3. 注入到 QML 引擎
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("todoModel", &todoModel);

    // 加载 UI
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
