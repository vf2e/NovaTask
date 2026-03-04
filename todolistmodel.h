#ifndef TODOLISTMODEL_H
#define TODOLISTMODEL_H

#include <QAbstractListModel>
#include "DatabaseManager.h"

class TodoListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int completedCount READ completedCount NOTIFY countChanged)
public:
    // 定义 QML 可以访问的角色名
    enum TaskRoles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        DescRole,
        IsCompletedRole,
        PriorityRole
    };

    explicit TodoListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // 供 QML 调用的接口 (Q_INVOKABLE)
    Q_INVOKABLE void loadTasks();
    Q_INVOKABLE void addTask(const QString &title, int priority = 1);
    Q_INVOKABLE void removeTask(int index);
    Q_INVOKABLE void toggleTask(int index);

    int completedCount() const {
        int count = 0;
        for(const auto& task : m_tasks) if(task.isCompleted) count++;
        return count;
    }
private:
    QList<TaskData> m_tasks;
signals:
    void countChanged();
};

#endif // TODOLISTMODEL_H
