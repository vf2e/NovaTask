QT += core gui quick sql quickcontrols2

RC_ICONS = assets/icons/logo.ico

SOURCES += \
        databasemanager.cpp \
        main.cpp \
        todolistmodel.cpp

RESOURCES += qml.qrc

QML_IMPORT_PATH =

QML_DESIGNER_IMPORT_PATH =

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    databasemanager.h \
    todolistmodel.h
