pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland._ToplevelManagement

Singleton {
    id: root

    // =======================================================================
    //  MangoWC state, as reported by the compositor.
    //
    //  MangoWC speaks JSON over `mmsg`:
    //      mmsg get   <query>   a one-shot query
    //      mmsg watch <query>   a persistent stream that re-emits a full JSON
    //                           snapshot on its own line whenever the queried
    //                           state changes
    //
    //  The two streams at the bottom of this file are the shell's only source
    //  of compositor state. Nothing here is guessed or optimistically updated:
    //  every property below is a projection of what the compositor last told us,
    //  so the UI can never drift out of sync with reality.
    // =======================================================================

    // `watch all-monitors` -> { monitors: [{ name, tags: [{ index, is_active,
    // client_count, ... }], active_tags: [n], keyboardlayout, keymode, ... }] }
    property var monitorState: null
    // `watch all-clients` -> { clients: [{ id, title, appid, tags: [n], x, y,
    // width, height, is_floating, is_fullscreen, ... }] }
    property var clientState: []

    // Tags are 1-based indices. The focused tag is the one MangoWC reports as
    // active; this is what the workspace indicators highlight.
    readonly property int activeTagNumber: monitorState?.active_tags?.[0] ?? 1
    readonly property int activeWsId: activeTagNumber
    readonly property int tagCount: Math.max(1, monitorState?.tags?.length ?? 1)
    readonly property string focusedOutput: monitorState?.name ?? ""

    // MangoWC reports the keyboard layout alongside the monitor state.
    readonly property string kbLayout: monitorState?.keyboardlayout ?? ""
    readonly property string kbLayoutFull: kbLayout
    readonly property string defaultKbLayout: kbLayout
    readonly property string currentLayout: monitorState?.layout_symbol ?? ""

    // MangoWC's client ids are exposed to the rest of the shell as Hyprland-style
    // hex addresses, so `address:0x…` selectors keep working.
    readonly property var focusedClientData: (clientState ?? []).find(c => c.is_focused) ?? null
    readonly property string focusedAddress: focusedClientData ? "0x" + (focusedClientData.id ?? 0) : "0x0"

    // Hyprland-shaped projections. The shell reads `.values` off these objects
    // and then `.id`, `.name`, `.workspace.id`, `.lastIpcObject.*`, so each entry
    // below has to carry that whole surface.
    readonly property var toplevelList: (clientState ?? []).map(client => root.toToplevel(client))
    readonly property var toplevels: ({ values: toplevelList })
    readonly property var parsedTags: (monitorState?.tags ?? []).map(tag => root.toWorkspace(tag))
    readonly property var workspaces: ({ values: parsedTags })
    readonly property var focusedToplevel: toplevelList.find(t => t.address === root.focusedAddress) ?? null

    // Placeholder so consumers can dereference `lastIpcObject` unconditionally
    // even when nothing is focused.
    readonly property var emptyIpcObject: root.buildIpcObject(null, root.activeTagNumber)

    readonly property QtObject focusedClient: QtObject {
        readonly property var wayland: ToplevelManager.activeToplevel?.window ?? null
        readonly property string title: root.focusedToplevel?.title ?? ""
        readonly property string appId: root.focusedToplevel?.appId ?? ""
        readonly property string address: root.focusedAddress
        readonly property var workspace: root.focusedWorkspace
        readonly property var monitor: root.focusedMonitor
        readonly property var lastIpcObject: root.focusedToplevel?.lastIpcObject ?? root.emptyIpcObject
    }

    // Persistent object (not a property-var literal) so its identity stays stable
    // across reads -- Visibilities.qml keys a Map by this object, and a fresh
    // literal here would also form a binding loop with focusedWorkspace, which
    // references this property back.
    readonly property QtObject focusedMonitor: QtObject {
        readonly property string name: root.focusedOutput
        readonly property int id: 0
        readonly property int x: root.monitorState?.x ?? 0
        readonly property int y: root.monitorState?.y ?? 0
        readonly property int width: root.monitorState?.width ?? 0
        readonly property int height: root.monitorState?.height ?? 0
        readonly property bool focused: true
        readonly property var lastIpcObject: ({ specialWorkspace: { name: "" } })
        readonly property var activeWorkspace: root.focusedWorkspace
    }

    readonly property var focusedWorkspace: root.toWorkspace({
        index: root.activeTagNumber,
        client_count: root.clientCountOnTag(root.activeTagNumber)
    })

    readonly property var activeToplevel: focusedClient
    readonly property var outputsList: monitorState ? [focusedMonitor] : []
    readonly property var monitors: outputsList

    // MangoWC exposes no keyboard/lock state, so these stay stubbed.
    readonly property var keyboard: null
    readonly property bool capsLock: false
    readonly property bool numLock: false
    readonly property bool hadKeyboard: false
    readonly property var kbMap: new Map()
    readonly property var availableLayouts: []
    readonly property var options: ({})

    // Extras placeholder (removed for MangoWC)
    readonly property var extras: ({
        devices: {
            keyboards: []
        },
        options: {},
        message: function() {},
        batchMessage: function() {},
        applyOptions: function() {},
        refreshOptions: function() {},
        refreshDevices: function() {}
    })

    readonly property var devices: extras.devices

    signal configReloaded

    // =======================================================================
    //  Incoming state
    // =======================================================================

    function parse(payload: string): var {
        try {
            const data = JSON.parse(payload);
            if (data?.error) {
                console.warn("MangoWC IPC:", data.error);
                return null;
            }
            return data;
        } catch (err) {
            console.error("MangoWC IPC: could not parse payload:", err, payload);
            return null;
        }
    }

    function applyMonitors(payload: string): void {
        const data = parse(payload);
        if (!data?.monitors?.length)
            return;

        monitorState = data.monitors.find(m => m.active) ?? data.monitors[0];
    }

    function applyClients(payload: string): void {
        const data = parse(payload);
        if (!data?.clients)
            return;

        clientState = data.clients;
    }

    // =======================================================================
    //  Projections
    // =======================================================================

    function clientCountOnTag(tag: int): int {
        const entry = (monitorState?.tags ?? []).find(t => t.index === tag);
        return entry?.client_count ?? 0;
    }

    function toplevelsOnTag(tag: int): var {
        return toplevelList.filter(t => t.workspace.id === tag);
    }

    function buildIpcObject(client: var, tag: int): var {
        return {
            "class": client?.appid ?? "",
            address: client ? "0x" + (client.id ?? 0) : "0x0",
            initialClass: client?.appid ?? "",
            initialTitle: client?.title ?? "",
            title: client?.title ?? "",
            at: [client?.x ?? 0, client?.y ?? 0],
            size: [client?.width ?? 0, client?.height ?? 0],
            // Hyprland uses 0 = tiled, 1 = maximised, 2 = fullscreen.
            fullscreen: client?.is_fullscreen ? 2 : client?.is_maximized ? 1 : 0,
            floating: !!client?.is_floating,
            // MangoWC's closest analogue to a pinned (always-on-top) window.
            pinned: !!client?.is_global,
            xwayland: !!client?.is_xwayland,
            pid: client?.pid ?? -1,
            workspace: {
                id: tag,
                name: String(tag)
            }
        };
    }

    function toToplevel(client: var): var {
        const tag = client?.tags?.[0] ?? root.activeTagNumber;

        return {
            address: "0x" + (client?.id ?? 0),
            title: client?.title ?? "",
            appId: client?.appid ?? "",
            // Only the focused window is ever handed to ScreencopyView, and
            // ToplevelManager already knows which one that is.
            wayland: client?.is_focused ? ToplevelManager.activeToplevel?.window ?? null : null,
            monitor: root.focusedMonitor,
            workspace: {
                id: tag,
                name: String(tag)
            },
            lastIpcObject: root.buildIpcObject(client, tag)
        };
    }

    function toWorkspace(tag: var): var {
        const index = tag?.index ?? root.activeTagNumber;

        return {
            id: index,
            // Tags have no user-assigned name in MangoWC. Using the bare index
            // keeps Workspace.qml's label logic (which falls back to the first
            // character of the name) showing the tag number.
            name: String(index),
            monitor: root.focusedMonitor,
            lastIpcObject: {
                windows: tag?.client_count ?? 0,
                specialWorkspace: { name: "" }
            },
            toplevels: { values: root.toplevelsOnTag(index) }
        };
    }

    // =======================================================================
    //  Dispatch
    //
    //  `mmsg dispatch <func>[,<arg>…][,client,<id>]` is the only way to ask
    //  MangoWC to do something. The names below are MangoWC's own compositor
    //  functions, not Hyprland's dispatcher syntax.
    // =======================================================================

    function send(func: string, args: string, client: int): void {
        const params = args.length > 0 ? args.split(",") : [];
        if (client >= 0)
            params.push("client", client.toString());

        Quickshell.execDetached(["mmsg", "dispatch", [func, ...params].join(",")]);
    }

    function dispatch(request: string): void {
        const [command, ...rest] = request.trim().split(/\s+/);

        // Hyprland selects a window with an `address:0x…` selector, which is
        // either its own argument or comma-appended to the last one (that is how
        // windowinfo/Buttons.qml writes it). MangoWC takes a `client,<id>` suffix
        // instead, where the id is the numeric client id that we already expose
        // as the window's address.
        let client = -1;
        let args = rest;
        const selector = /address:(0x[0-9a-fA-F]+)/.exec(request);
        if (selector) {
            const id = parseInt(selector[1].slice(2), 10);
            if (!Number.isNaN(id))
                client = id;
            args = rest.flatMap(a => a.split(",")).filter(a => !a.startsWith("address:"));
        }

        switch (command) {
        case "workspace":
        case "view": {
            const to = args[0];
            if (to?.startsWith("r")) {
                // Relative switch, e.g. the bar's `workspace r+1` scroll action.
                send(to === "r-1" ? "viewtoleft" : "viewtoright", "0");
            } else {
                send("comboview", to ?? "");
            }
            return;
        }
        case "movetoworkspace":
            send("tag", args[0] ?? "", client);
            return;
        case "killwindow":
        case "closewindow":
        case "killclient":
            send("killclient", "", client);
            return;
        case "togglefloating":
            send("togglefloating", "", client);
            return;
        case "focusdir":
            send("focusdir", args.join(","));
            return;
        case "cyclelayout":
            send("switch_layout", "1");
            return;
        case "pin":
            console.warn("MangoWC: pinned windows are not supported");
            return;
        case "togglespecialworkspace":
            console.warn("MangoWC: special workspaces are not supported");
            return;
        default:
            // Forwarded verbatim, e.g. `spawn …` or a MangoWC function by name.
            send(command, args.join(","));
            return;
        }
    }

    function monitorFor(screen): var {
        // MangoWC doesn't have per-screen monitor info easily accessible via Wayland protocols;
        // this is single-monitor-only, so return the same cached object as focusedMonitor
        // rather than a fresh literal each call -- Visibilities.qml keys a Map by object
        // identity, and a fresh object here would never match on lookup.
        return root.focusedMonitor;
    }

    function reloadDynamicConfs(): void {
        send("reload_config", "");
        configReloaded();
    }

    // =======================================================================
    //  State streams
    // =======================================================================

    Process {
        id: monitorStream

        command: ["mmsg", "watch", "all-monitors"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.applyMonitors(data)
        }
    }

    Process {
        id: clientStream

        command: ["mmsg", "watch", "all-clients"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.applyClients(data)
        }
    }

    // Both streams are long-lived and exit when the compositor goes away, so
    // restart them to let the shell recover from a compositor restart.
    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            if (!monitorStream.running)
                monitorStream.running = true;
            if (!clientStream.running)
                clientStream.running = true;
        }
    }
}
