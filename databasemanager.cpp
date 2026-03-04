#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initDatabase()
{
    // 将数据库文件存放在系统的 AppData 目录下，这是标准做法
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    QString dbPath = dir.absoluteFilePath(DB_NAME);

    if (QSqlDatabase::contains("qt_sql_default_connection")) {
        m_db = QSqlDatabase::database("qt_sql_default_connection");
    } else {
        m_db = QSqlDatabase::addDatabase("QSQLITE");
    }

    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qCritical() << "Error: Connection with database fail" << m_db.lastError();
        return false;
    }

    qDebug() << "Database connected successfully at:" << dbPath;
    return createTables();
}

bool DatabaseManager::createTables()
{
    QSqlQuery query;
    // 创建任务表：引入 priority 字段，为后续的时间管理矩阵做准备
    QString createSql = R"(
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            is_completed INTEGER DEFAULT 0,
            priority INTEGER DEFAULT 1,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    )";

    if (!query.exec(createSql)) {
        qCritical() << "Couldn't create the table 'tasks': one might already exist." << query.lastError();
        return false;
    }
    return true;
}

bool DatabaseManager::addTask(const TaskData& task)
{
    QSqlQuery query;
    query.prepare("INSERT INTO tasks (title, description, is_completed, priority, created_at) "
                  "VALUES (:title, :description, :is_completed, :priority, :created_at)");
    query.bindValue(":title", task.title);
    query.bindValue(":description", task.description);
    query.bindValue(":is_completed", task.isCompleted ? 1 : 0);
    query.bindValue(":priority", task.priority);
    query.bindValue(":created_at", QDateTime::currentDateTime());

    if (!query.exec()) {
        qCritical() << "Error adding task:" << query.lastError();
        return false;
    }
    return true;
}

bool DatabaseManager::updateTaskStatus(int id, bool isCompleted)
{
    QSqlQuery query;
    query.prepare("UPDATE tasks SET is_completed = :status WHERE id = :id");
    query.bindValue(":status", isCompleted ? 1 : 0);
    query.bindValue(":id", id);
    return query.exec();
}

bool DatabaseManager::deleteTask(int id)
{
    QSqlQuery query;
    query.prepare("DELETE FROM tasks WHERE id = :id");
    query.bindValue(":id", id);
    return query.exec();
}

QList<TaskData> DatabaseManager::getAllTasks()
{
    QList<TaskData> taskList;
    QSqlQuery query("SELECT id, title, description, is_completed, priority, created_at FROM tasks ORDER BY is_completed ASC, priority DESC, created_at DESC");

    while (query.next()) {
        TaskData task;
        task.id = query.value(0).toInt();
        task.title = query.value(1).toString();
        task.description = query.value(2).toString();
        task.isCompleted = query.value(3).toInt() == 1;
        task.priority = query.value(4).toInt();
        task.createdAt = query.value(5).toDateTime();
        taskList.append(task);
    }
    return taskList;
}
