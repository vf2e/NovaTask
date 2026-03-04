#include "TodoListModel.h"

TodoListModel::TodoListModel(QObject *parent) : QAbstractListModel(parent) {}

int TodoListModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_tasks.count();
}

QVariant TodoListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_tasks.count()) return QVariant();

    const TaskData &task = m_tasks.at(index.row());
    switch (role) {
    case IdRole: return task.id;
    case TitleRole: return task.title;
    case DescRole: return task.description;
    case IsCompletedRole: return task.isCompleted;
    case PriorityRole: return task.priority;
    }
    return QVariant();
}

QHash<int, QByteArray> TodoListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[TitleRole] = "title";
    roles[DescRole] = "description";
    roles[IsCompletedRole] = "isCompleted";
    roles[PriorityRole] = "priority";
    return roles;
}

void TodoListModel::loadTasks() {
    beginResetModel(); // 强力重置整个 UI 列表
    m_tasks = DatabaseManager::instance().getAllTasks();
    endResetModel();
}

void TodoListModel::addTask(const QString &title, int priority) {
    if (title.trimmed().isEmpty()) return;

    TaskData newTask;
    newTask.title = title;
    newTask.priority = priority; // 1:普通, 2:重要, 3:紧急
    newTask.isCompleted = false;

    if (DatabaseManager::instance().addTask(newTask)) {
        beginResetModel(); // 简单起见，重新加载以触发排序
        m_tasks = DatabaseManager::instance().getAllTasks();
        endResetModel();
        emit countChanged();
    }
}

void TodoListModel::removeTask(int index) {
    if (index < 0 || index >= m_tasks.count()) return;

    int dbId = m_tasks[index].id;
    if (DatabaseManager::instance().deleteTask(dbId)) {
        // 触发 QML 的 ListView 移除动画 (remove Transition)
        beginRemoveRows(QModelIndex(), index, index);
        m_tasks.removeAt(index);
        endRemoveRows();
    }
}

void TodoListModel::toggleTask(int index) {
    if (index < 0 || index >= m_tasks.count()) return;

    m_tasks[index].isCompleted = !m_tasks[index].isCompleted;
    DatabaseManager::instance().updateTaskStatus(m_tasks[index].id, m_tasks[index].isCompleted);

    // 局部刷新：只更新这一行的状态，避免整个 UI 闪烁。这是顶级优化的核心！
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {IsCompletedRole});
    emit countChanged();
}
