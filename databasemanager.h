#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>
#include <QDateTime>

// 定义任务结构体，方便数据传输
struct TaskData {
    int id = -1;
    QString title;
    QString description;
    bool isCompleted = false;
    int priority = 1; // 1: 普通, 2: 重要, 3: 紧急且重要 (艾森豪威尔矩阵)
    QDateTime createdAt;
};

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    // 经典的 Meyers 单例模式，C++11 线程安全
    static DatabaseManager& instance() {
        static DatabaseManager instance;
        return instance;
    }

    // 禁止拷贝和赋值
    DatabaseManager(const DatabaseManager&) = delete;
    void operator=(const DatabaseManager&) = delete;

    bool initDatabase();

    // CRUD 基础接口
    bool addTask(const TaskData& task);
    bool updateTaskStatus(int id, bool isCompleted);
    bool deleteTask(int id);
    QList<TaskData> getAllTasks();

private:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    QSqlDatabase m_db;
    const QString DB_NAME = "novatask_core.db";

    bool createTables();
};

#endif // DATABASEMANAGER_H
