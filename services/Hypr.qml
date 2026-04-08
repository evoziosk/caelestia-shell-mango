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
    property string lastSpecialWorkspace: ""

    signal configReloaded

    function dispatch(request: string): void {
        Services.Mango.dispatch(request);
    }

    function cycleSpecialWorkspace(direction: string): void {
        const openSpecials = workspaces.values.filter(w => w.name.startsWith("special:") && w.lastIpcObject.windows > 0);

        if (openSpecials.length === 0)
            return;

        const activeSpecial = focusedMonitor?.lastIpcObject?.specialWorkspace?.name ?? "";

        if (!activeSpecial) {
            if (lastSpecialWorkspace) {
                const workspace = workspaces.values.find(w => w.name === lastSpecialWorkspace);
                if (workspace && workspace.lastIpcObject.windows > 0) {
                    dispatch(`workspace ${lastSpecialWorkspace}`);
                    return;
                }
            }
            dispatch(`workspace ${openSpecials[0].name}`);
            return;
        }

        const currentIndex = openSpecials.findIndex(w => w.name === activeSpecial);
        let nextIndex = 0;

        if (currentIndex !== -1) {
            if (direction === "next")
                nextIndex = (currentIndex + 1) % openSpecials.length;
            else
                nextIndex = (currentIndex - 1 + openSpecials.length) % openSpecials.length;
        }

        dispatch(`workspace ${openSpecials[nextIndex].name}`);
    }

    function monitorNames(): list<string> {
        return monitors.values.map(e => e.name);
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
