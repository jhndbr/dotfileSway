#!/usr/bin/env python3
"""
Provisional / Fallback D-Bus Notification Daemon (org.freedesktop.Notifications)
Prevents libnotify / Electron / Antigravity from freezing or crashing when
Quickshell is not yet compiled or not running.
"""
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib


class NotificationFallback(dbus.service.Object):
    def __init__(self, bus_name):
        super().__init__(bus_name, "/org/freedesktop/Notifications")
        self._next_id = 1

    @dbus.service.method(
        "org.freedesktop.Notifications",
        in_signature="",
        out_signature="as",
    )
    def GetCapabilities(self):
        return ["body", "actions", "icon-static"]

    @dbus.service.method(
        "org.freedesktop.Notifications",
        in_signature="susssasa{sv}i",
        out_signature="u",
    )
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout):
        if replaces_id > 0:
            nid = replaces_id
        else:
            nid = self._next_id
            self._next_id += 1
        return dbus.UInt32(nid)

    @dbus.service.method(
        "org.freedesktop.Notifications",
        in_signature="u",
        out_signature="",
    )
    def CloseNotification(self, nid):
        self.NotificationClosed(dbus.UInt32(nid), dbus.UInt32(3))

    @dbus.service.method(
        "org.freedesktop.Notifications",
        in_signature="",
        out_signature="ssss",
    )
    def GetServerInformation(self):
        return ("SwayShell-Fallback", "SwayShell", "1.0", "1.2")

    @dbus.service.signal(
        "org.freedesktop.Notifications",
        signature="uu",
    )
    def NotificationClosed(self, id, reason):
        pass

    @dbus.service.signal(
        "org.freedesktop.Notifications",
        signature="us",
    )
    def ActionInvoked(self, id, action_key):
        pass


if __name__ == "__main__":
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    session_bus = dbus.SessionBus()
    loop = GLib.MainLoop()
    bus_name = dbus.service.BusName(
        "org.freedesktop.Notifications",
        session_bus,
        allow_replacement=True,
        replace_existing=True,
        do_not_queue=True,
    )
    daemon = NotificationFallback(bus_name)
    session_bus.add_signal_receiver(
        lambda name: loop.quit() if name == "org.freedesktop.Notifications" else None,
        signal_name="NameLost",
        dbus_interface="org.freedesktop.DBus",
    )
    loop.run()
