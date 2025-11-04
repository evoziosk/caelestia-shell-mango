pragma Singleton

// Compatibility layer: Redirect to Mango.qml for MangoWC support
import qs.services as Services
import QtQuick

QtObject {
    id: root

    // Export all Mango properties as if they were Hypr properties
    readonly property var toplevels: Services.Mango.toplevels
    readonly property var workspaces: Services.Mango.workspaces
    readonly property var monitors: Services.Mango.monitors

    readonly property var activeToplevel: Services.Mango.activeToplevel
    readonly property var focusedWorkspace: Services.Mango.focusedWorkspace
    readonly property var focusedMonitor: Services.Mango.focusedMonitor
    readonly property int activeWsId: Services.Mango.activeWsId

    readonly property var keyboard: Services.Mango.keyboard
    readonly property bool capsLock: Services.Mango.capsLock
    readonly property bool numLock: Services.Mango.numLock
    readonly property string defaultKbLayout: Services.Mango.defaultKbLayout
    readonly property string kbLayoutFull: Services.Mango.kbLayoutFull
    readonly property string kbLayout: Services.Mango.kbLayout
    readonly property var kbMap: Services.Mango.kbMap

    readonly property var extras: Services.Mango.extras
    readonly property var options: Services.Mango.options
    readonly property var devices: Services.Mango.devices

    property bool hadKeyboard: Services.Mango.hadKeyboard

    signal configReloaded

    function dispatch(request: string): void {
        Services.Mango.dispatch(request);
    }

    function monitorFor(screen): var {
        return Services.Mango.monitorFor(screen);
    }

    function reloadDynamicConfs(): void {
        Services.Mango.reloadDynamicConfs();
    }

    Component.onCompleted: {
        Services.Mango.configReloaded.connect(root.configReloaded);
    }
}

