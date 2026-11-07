pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import ".."

Singleton {
    id: root

    // List of active notification toast items
    property var notifications: []
    readonly property int count: notifications.length
    property bool doNotDisturb: false

    function toggleDnd() {
        doNotDisturb = !doNotDisturb;
    }

    signal notificationAdded(var notif)
    signal notificationRemoved(int id)

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: (notif) => {
            notif.tracked = true;

            const item = {
                id: notif.id,
                obj: notif,
                appName: notif.appName || "Notification",
                appIcon: notif.appIcon || "",
                summary: notif.summary || "",
                body: notif.body || "",
                actions: notif.actions ? Array.from(notif.actions) : [],
                time: new Date()
            };

            // If Do Not Disturb is active, dismiss immediately without showing toast
            if (root.doNotDisturb) {
                return;
            }

            // Add to beginning or end
            const updated = [item, ...root.notifications];
            if (updated.length > Config.maxNotificationsVisible) {
                updated.pop();
            }
            root.notifications = updated;
            root.notificationAdded(item);

            // Setup auto-dismiss timer
            const timeout = notif.expireTimeout > 0 ? notif.expireTimeout : Config.notificationTimeout;
            if (timeout > 0) {
                dismissTimerComp.createObject(root, {
                    notifId: notif.id,
                    interval: timeout
                });
            }
        }
    }

    Component {
        id: dismissTimerComp
        Timer {
            property int notifId
            repeat: false
            running: true
            onTriggered: {
                root.dismiss(notifId);
                destroy();
            }
        }
    }

    function dismiss(id) {
        const found = root.notifications.find(n => n.id === id);
        if (found && found.obj) {
            try {
                found.obj.dismiss();
            } catch (e) {}
        }
        root.notifications = root.notifications.filter(n => n.id !== id);
        root.notificationRemoved(id);
    }

    function dismissAll() {
        for (let i = 0; i < root.notifications.length; i++) {
            const notif = root.notifications[i];
            if (notif.obj) {
                try {
                    notif.obj.dismiss();
                } catch (e) {}
            }
        }
        root.notifications = [];
    }

    function invokeAction(notifId, actionKey) {
        const notif = root.notifications.find(n => n.id === notifId);
        if (notif && notif.obj && notif.obj.actions) {
            const action = notif.obj.actions.find(a => a.identifier === actionKey);
            if (action) {
                try {
                    action.invoke();
                } catch (e) {
                    console.warn("[NotificationService] Action failed:", e);
                }
            }
        }
        dismiss(notifId);
    }
}
