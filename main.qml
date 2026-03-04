import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

ApplicationWindow {
    id: window
    visible: true
    width: 600; height: 1000
    title: "NovaTask"
    color: "transparent"

    QtObject {
        id: theme
        readonly property color primary: "#6366F1"
        readonly property color secondary: "#A855F7"
        readonly property color accent: "#EC4899"
        readonly property var quadrantColors: [
            "#EF4444", // 重要且紧急 (红)
            "#F59E0B", // 重要不紧急 (橙)
            "#3B82F6", // 不重要但紧急 (蓝)
            "#6B7280"  // 不重要不紧急 (灰)
        ]
        readonly property var quadrantNames: [
            "重要且紧急",
            "重要不紧急",
            "不重要但紧急",
            "不重要不紧急"
        ]
        // 对应象限的 Emoji 图标
        readonly property var quadrantEmoji: [
            "🔥",  // 重要且紧急
            "📅",  // 重要不紧急
            "⚡",  // 不重要但紧急
            "💤"   // 不重要不紧急
        ]
        // 背景色系
        readonly property color bgDark: "#0B0E17"
        readonly property color glassBg: "#1E2230CC"
        readonly property color glassBorder: "#33FFFFFF"
        readonly property color textPrimary: "#FFFFFF"
        readonly property color textSecondary: "#9CA3AF"
        readonly property real radiusCard: 28
        readonly property real radiusItem: 22
    }

    Item {
        anchors.fill: parent
        z: -2

        Rectangle {
            anchors.fill: parent
            color: theme.bgDark
        }

        Rectangle {
            width: parent.width * 2; height: parent.height * 2
            x: -parent.width * 0.5; y: -parent.height * 0.5
            gradient: Gradient {
                orientation: Gradient.Radial
                GradientStop { position: 0.0; color: Qt.rgba(0.39, 0.29, 0.93, 0.2) }
                GradientStop { position: 0.5; color: Qt.rgba(0.2, 0.6, 0.9, 0.1) }
                GradientStop { position: 1.0; color: "transparent" }
            }
            layer.enabled: true
            layer.effect: FastBlur { radius: 120 }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { from: -parent.width*0.5; to: -parent.width*0.3; duration: 15000; easing.type: Easing.InOutSine }
                NumberAnimation { from: -parent.width*0.3; to: -parent.width*0.5; duration: 15000; easing.type: Easing.InOutSine }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            opacity: 0.03
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: ShaderEffectSource {
                    sourceItem: Item {
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.fillStyle = "#FFFFFF";
                                for (var i=0; i<200; i++) {
                                    ctx.fillRect(Math.random()*width, Math.random()*height, 1, 1);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 16

            Column {
                spacing: 4
                Text {
                    text: "NovaTask"
                    color: theme.textPrimary
                    font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 30; weight: Font.Black; letterSpacing: -0.5 }
                }
                Text {
                    text: new Date().toLocaleDateString(Qt.locale(), "dddd, MMM d")
                    color: theme.textSecondary
                    font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 14 }
                }
            }

            Item { Layout.fillWidth: true }

            Item {
                width: 80; height: 80
                readonly property int total: todoModel.count
                readonly property int completed: todoModel.completedCount
                readonly property real progress: total > 0 ? completed / total : 0

                Canvas {
                    id: progressCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.beginPath();
                        ctx.arc(width/2, height/2, width/2 - 4, 0, Math.PI*2);
                        ctx.strokeStyle = "#33FFFFFF";
                        ctx.lineWidth = 3;
                        ctx.stroke();

                        if (parent.progress > 0) {
                            ctx.beginPath();
                            ctx.arc(width/2, height/2, width/2 - 4, -Math.PI/2, -Math.PI/2 + parent.progress * Math.PI*2);
                            ctx.strokeStyle = theme.primary;
                            ctx.lineWidth = 4;
                            ctx.stroke();
                        }
                    }
                    Connections {
                        target: todoModel
                        function onDataChanged() { progressCanvas.requestPaint(); }
                        function onRowsInserted() { progressCanvas.requestPaint(); }
                        function onRowsRemoved() { progressCanvas.requestPaint(); }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: Math.round(progressCanvas.parent.progress * 100) + "%"
                    color: theme.textPrimary
                    font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 18; weight: Font.Bold }
                }
            }
        }

        Rectangle {
            id: addCard
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            radius: theme.radiusCard
            color: theme.glassBg
            border.color: theme.glassBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    TextField {
                        id: taskInput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        placeholderText: "写下一个任务..."
                        placeholderTextColor: theme.textSecondary
                        color: theme.textPrimary
                        font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 16 }
                        leftPadding: 16
                        background: Rectangle {
                            color: "#3A1E2230"
                            radius: 12
                            border.color: taskInput.activeFocus ? theme.primary : "transparent"
                            border.width: 1
                        }
                        Keys.onReturnPressed: submitTask()
                    }

                    Rectangle {
                        width: 50; height: 50; radius: 16
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: theme.primary }
                            GradientStop { position: 1.0; color: theme.secondary }
                        }
                        scale: addMouse.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                        Text {
                            anchors.centerIn: parent
                            text: "＋"
                            color: "white"
                            font.pixelSize: 28
                        }

                        MouseArea {
                            id: addMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: submitTask()
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "选择优先级象限"
                        color: theme.textSecondary
                        font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 12; weight: Font.Medium; letterSpacing: 0.5 }
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 8; columnSpacing: 8
                        Layout.fillWidth: true

                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                radius: 16
                                color: quadrantMouse.containsMouse ? Qt.lighter(theme.quadrantColors[index], 1.2) : "#1AFFFFFF"
                                border.color: prioritySelector.selectedQuadrant === index ? theme.quadrantColors[index] : "transparent"
                                border.width: 2

                                property int quadrantIndex: index

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: theme.quadrantEmoji[index]
                                        color: theme.quadrantColors[index]
                                        font { family: "Segoe UI Emoji, Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 24 }
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: theme.quadrantNames[index]
                                        color: theme.quadrantColors[index]
                                        font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 12; weight: Font.Medium }
                                        opacity: 0.9
                                    }
                                }

                                MouseArea {
                                    id: quadrantMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: prioritySelector.selectedQuadrant = quadrantIndex
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors.fill: parent
                model: todoModel
                spacing: 12
                clip: true

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
                    NumberAnimation { property: "scale"; from: 0.8; to: 1; duration: 400; easing.type: Easing.OutBack }
                }
                remove: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                        NumberAnimation { property: "scale"; to: 0.8; duration: 200 }
                    }
                }

                delegate: Item {
                    width: listView.width
                    height: taskCard.implicitHeight + 4

                    Rectangle {
                        id: taskCard
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: theme.radiusItem
                        color: theme.glassBg
                        border.color: mouseArea.containsMouse ? theme.quadrantColors[model.priority-1] : theme.glassBorder
                        border.width: mouseArea.containsMouse ? 2 : 1

                        implicitHeight: contentRow.implicitHeight + 32

                        RowLayout {
                            id: contentRow
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14
                            Rectangle {
                                width: 28; height: 28; radius: 8
                                color: model.isCompleted ? theme.quadrantColors[model.priority-1] : "transparent"
                                border.color: model.isCompleted ? "transparent" : theme.glassBorder
                                border.width: 2

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: "white"
                                    font.bold: true
                                    visible: model.isCompleted
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        todoModel.toggleTask(index)
                                        snackbar.show(model.isCompleted ? "任务已完成 ✨" : "已取消完成", "neutral")
                                    }
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    width: parent.width
                                    text: model.title
                                    color: model.isCompleted ? theme.textSecondary : theme.textPrimary
                                    font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 16; weight: Font.Medium; strikeout: model.isCompleted }
                                    wrapMode: Text.WordWrap
                                }

                                Row {
                                    spacing: 6
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: theme.quadrantColors[model.priority-1]
                                    }
                                    Text {
                                        text: theme.quadrantNames[model.priority-1]
                                        color: theme.textSecondary
                                        font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 11 }
                                    }
                                }
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 10
                                color: deleteMouse.containsMouse ? "#33EF4444" : "transparent"
                                border.color: deleteMouse.containsMouse ? "#EF4444" : theme.glassBorder
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: deleteMouse.containsMouse ? "#EF4444" : theme.textSecondary
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    id: deleteMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        todoModel.removeTask(index)
                                        snackbar.show("任务已删除", "error")
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        propagateComposedEvents: true
                        onClicked: mouse.accepted = false
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "✨ 还没有任务，添加一条吧"
                color: theme.textSecondary
                font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 16 }
                visible: todoModel.count === 0
            }
        }
    }

    Rectangle {
        id: snackbar
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height + 20
        width: Math.min(300, parent.width - 40)
        height: 52
        radius: 26
        color: {
            if (snackbar.type === "success") return "#2E7D32CC"
            if (snackbar.type === "error") return "#EF4444"
            return "#1F2937CC"
        }
        border.color: {
            if (snackbar.type === "success") return "#66BB6A"
            if (snackbar.type === "error") return "#EF5350"
            return "#4B5563"
        }
        border.width: 1

        property string type: "neutral"
        property string message: ""

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20; anchors.rightMargin: 20
            spacing: 12

            Text {
                text: {
                    if (snackbar.type === "success") return "✓"
                    if (snackbar.type === "error") return "👌"
                    return "ℹ"
                }
                color: "white"
                font.pixelSize: 20
            }

            Text {
                Layout.fillWidth: true
                text: snackbar.message
                color: "white"
                font { family: "Segoe UI, Microsoft YaHei, sans-serif"; pixelSize: 14; weight: Font.Medium }
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        SequentialAnimation {
            id: snackbarAnim
            NumberAnimation { target: snackbar; property: "y"; to: window.height - 120; duration: 400; easing.type: Easing.OutBack }
            PauseAnimation { duration: 2000 }
            NumberAnimation { target: snackbar; property: "opacity"; to: 0; duration: 300 }
            PropertyAction { target: snackbar; property: "visible"; value: false }
            PropertyAction { target: snackbar; property: "opacity"; value: 1.0 }
            PropertyAction { target: snackbar; property: "y"; value: window.height + 20 }
        }

        function show(msg, type = "neutral") {
            message = msg;
            snackbar.type = type;
            visible = true;
            snackbarAnim.restart();
        }
    }

    QtObject {
        id: prioritySelector
        property int selectedQuadrant: 0
    }

    function submitTask() {
        var text = taskInput.text.trim();
        if (text === "") {
            snackbar.show("请填写任务内容", "neutral");
            return;
        }
        todoModel.addTask(text, prioritySelector.selectedQuadrant + 1);
        taskInput.clear();
        taskInput.focus = true;
        snackbar.show("任务已添加 ✨", "success");
    }

    ListModel {
        id: todoModel
        property int completedCount: 0

        function addTask(title, priority) {
            todoModel.append({ title: title, priority: priority, isCompleted: false });
        }

        function toggleTask(index) {
            var item = todoModel.get(index);
            item.isCompleted = !item.isCompleted;
            completedCount = calculateCompleted();
        }

        function removeTask(index) {
            todoModel.remove(index);
            completedCount = calculateCompleted();
        }

        function calculateCompleted() {
            var count = 0;
            for (var i = 0; i < todoModel.count; i++) {
                if (todoModel.get(i).isCompleted) count++;
            }
            return count;
        }
    }
}
