pragma Singleton

import qs.components.misc
import qs.config
import Caelestia
import Quickshell
import Quickshell.Io
import Quickshell.Wayland._ToplevelManagement
import QtQuick

Singleton {
    id: root

    // MangoWC workspaces (tags) via Wayland protocols
    readonly property var toplevels: ({
        values: ToplevelManager.toplevels || []
    }) // Real window list with .values accessor
    
    readonly property var workspaces: ({
        values: parsedTags
    }) // Workspace list with .values accessor
    
    readonly property var monitors: outputsList // Monitor list - still stubbed

    // Active window with full compatibility layer
    readonly property var activeToplevel: focusedClient
    
    // Compatibility wrapper for window info that needs lastIpcObject
    readonly property QtObject focusedClient: QtObject {
        readonly property var wayland: ToplevelManager.activeToplevel
        readonly property string title: ToplevelManager.activeToplevel?.title ?? ""
        readonly property string appId: ToplevelManager.activeToplevel?.appId ?? ""
        readonly property string address: "0x0"
        readonly property var workspace: focusedWorkspace
        readonly property var monitor: focusedMonitor
        
        readonly property var lastIpcObject: {
            const obj = {
                title: ToplevelManager.activeToplevel?.title ?? "",
                initialTitle: ToplevelManager.activeToplevel?.title ?? "",
                initialClass: ToplevelManager.activeToplevel?.appId ?? "",
                floating: focusedClientFloating,
                fullscreen: focusedClientFullscreen ? 2 : 0,
                at: [focusedClientX, focusedClientY],
                size: [focusedClientWidth, focusedClientHeight],
                workspace: { "id": activeTagNumber, "name": `tag ${activeTagNumber}` },
                address: "0x0",
                pid: -1,
                xwayland: false,
                pinned: false
            };
            // Set 'class' property (reserved keyword)
            obj["class"] = ToplevelManager.activeToplevel?.appId ?? "";
            return obj;
        }
    }

    readonly property var focusedMonitor: ({
        name: focusedOutput,
        id: 0,
        x: 0,
        y: 0,
        focused: true,
        lastIpcObject: {
            specialWorkspace: { name: "" }
        }
    }) // Current focused monitor
    
    readonly property var focusedWorkspace: ({
        id: activeTagNumber,
        name: `tag ${activeTagNumber}`,
        lastIpcObject: {
            windows: ToplevelManager.toplevels.length,  // Actual window count
            specialWorkspace: { name: "" }
        },
        monitor: focusedMonitor,
        toplevels: { values: ToplevelManager.toplevels }
    }) // Current focused workspace

    readonly property int activeWsId: activeTagNumber

    // Mango tag state
    property var parsedTags: []
    property int activeTags: 0
    property int occupiedTags: 0
    property int activeTagNumber: 1
    property string focusedOutput: ""
    property var outputsList: []

    // Client info
    property string focusedClientTitle: ""
    property string focusedClientAppId: ""
    property int focusedClientX: 0
    property int focusedClientY: 0
    property int focusedClientWidth: 0
    property int focusedClientHeight: 0
    property bool focusedClientFloating: false
    property bool focusedClientFullscreen: false

    // Layout
    property string currentLayout: ""
    property var availableLayouts: []

    // Keyboard state (MangoWC doesn't expose this, so we stub it)
    readonly property var keyboard: null
    readonly property bool capsLock: false
    readonly property bool numLock: false
    readonly property string defaultKbLayout: ""
    readonly property string kbLayoutFull: currentKbLayout
    readonly property string kbLayout: currentKbLayout

    property string currentKbLayout: ""
    property bool hadKeyboard: false

    readonly property var kbMap: new Map()

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

    readonly property var options: ({})
    readonly property var devices: extras.devices

    signal configReloaded

    function dispatch(request: string): void {
        // MangoWC dispatch via mmsg -d
        const parts = request.split(" ");
        const command = parts[0];
        const args = parts.slice(1);
        
        // Map Hyprland commands to MangoWC mmsg commands
        if (command === "killwindow" || command === "closewindow" || command === "killclient") {
            Quickshell.execDetached(["mmsg", "-d", "killclient"]);
        } else if (command === "togglefloating") {
            Quickshell.execDetached(["mmsg", "-d", "togglefloating"]);
        } else if (command === "togglefullscreen" || command === "fullscreen") {
            Quickshell.execDetached(["mmsg", "-d", "togglefullscreen"]);
        } else if (command === "pin") {
            Quickshell.execDetached(["mmsg", "-d", "togglepin"]);
        } else if (command === "workspace" || command === "tag") {
            // Switch to workspace/tag
            const tagNum = parseInt(args[0]);
            if (!isNaN(tagNum)) {
                Quickshell.execDetached(["mmsg", "-t", tagNum.toString()]);
                activeTagNumber = tagNum;
            }
        } else if (command === "movetoworkspace") {
            // Move window to tag
            const tagNum = parseInt(args[0].replace(/^[^0-9]*/, ""));
            if (!isNaN(tagNum)) {
                Quickshell.execDetached(["mmsg", "-s", "-t", tagNum + "+"]);
            }
        } else if (command === "togglespecialworkspace") {
            console.warn("MangoWC: Special workspaces not supported");
        } else if (command.startsWith("resize")) {
            // resizewin
            Quickshell.execDetached(["mmsg", "-d", "resizewin," + args.join(",")]);
        } else if (command.startsWith("move")) {
            // movewin
            Quickshell.execDetached(["mmsg", "-d", "movewin," + args.join(",")]);
        } else if (command === "focusdir") {
            Quickshell.execDetached(["mmsg", "-d", "focusdir," + args[0]]);
        } else if (command === "cyclelayout") {
            // Cycle through layouts
            Quickshell.execDetached(["mmsg", "-d", "cyclelayout"]);
        } else {
            // Try as direct dispatch
            const fullCmd = [command, ...args].join(",");
            console.log("MangoWC: Dispatching:", fullCmd);
            Quickshell.execDetached(["mmsg", "-d", fullCmd]);
        }
    }

    function monitorFor(screen): var {
        // MangoWC doesn't have per-screen monitor info easily accessible via Wayland protocols
        return {
            name: focusedOutput,
            id: 0,
            focused: true,
            lastIpcObject: {
                specialWorkspace: { name: "" }
            },
            activeWorkspace: focusedWorkspace
        };
    }

    function reloadDynamicConfs(): void {
        // MangoWC doesn't have dynamic config reloading via IPC
        console.log("MangoWC: Dynamic config reload not supported");
    }

    Component.onCompleted: {
        reloadDynamicConfs();
        console.log("MangoWC: Using Wayland protocols + mmsg IPC");
        console.log("MangoWC: Toplevels available:", toplevels.values.length);
        
        // Initialize with some default tags
        const tags = [];
        for (let i = 1; i <= 9; i++) {
            tags.push({
                id: i,
                name: `tag ${i}`,
                lastIpcObject: {
                    windows: 0,
                    specialWorkspace: { name: "" }
                },
                monitor: focusedMonitor,
                toplevels: { values: [] }
            });
        }
        parsedTags = tags;
    }
    
    // Poll tag state periodically
    Timer {
        interval: 200 // Poll every 200ms for faster response
        running: true
        repeat: true
        onTriggered: {
            tagStateProcess.running = false;
            tagStateProcess.running = true;
            focusedClientProcess.running = false;
            focusedClientProcess.running = true;
            focusedClientGeometryProcess.running = false;
            focusedClientGeometryProcess.running = true;
            focusedClientFloatingProcess.running = false;
            focusedClientFloatingProcess.running = true;
            focusedClientFullscreenProcess.running = false;
            focusedClientFullscreenProcess.running = true;
        }
    }
    
    Process {
        id: tagStateProcess
        command: ["mmsg", "-g", "-t"]
        stdout: StdioCollector {
            onStreamFinished: parseTagState(text)
        }
    }
    
    Process {
        id: focusedClientProcess
        command: ["mmsg", "-g", "-c"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                for (const line of lines) {
                    if (line.includes(" title ")) {
                        focusedClientTitle = line.split(" title ")[1] || "";
                    } else if (line.includes(" appid ")) {
                        focusedClientAppId = line.split(" appid ")[1] || "";
                    }
                }
            }
        }
    }
    
    Process {
        id: focusedClientGeometryProcess
        command: ["mmsg", "-g", "-x"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                // Debug disabled: console.log("MangoWC: Geometry update:", text.substring(0, 100));
                for (const line of lines) {
                    const parts = line.split(/\s+/);
                    if (parts.length >= 3) {
                        const prop = parts[1];
                        const value = parseInt(parts[2]);
                        if (prop === "x") focusedClientX = value;
                        else if (prop === "y") focusedClientY = value;
                        else if (prop === "width") focusedClientWidth = value;
                        else if (prop === "height") focusedClientHeight = value;
                    }
                }
            }
        }
    }
    
    Process {
        id: focusedClientFloatingProcess
        command: ["mmsg", "-g", "-f"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                for (const line of lines) {
                    if (line.includes(" floating ")) {
                        focusedClientFloating = line.split(" floating ")[1] === "1";
                    }
                }
            }
        }
    }
    
    Process {
        id: focusedClientFullscreenProcess
        command: ["mmsg", "-g", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                for (const line of lines) {
                    if (line.includes(" fullscreen ")) {
                        focusedClientFullscreen = line.split(" fullscreen ")[1] === "1";
                    }
                }
            }
        }
    }
    
    function parseTagState(output: string): void {
        try {
            const lines = output.trim().split('\n');
            let focusedTagMask = 0;
            let visibleTagMask = 0;
            const occupiedMap = {};
            
            for (const line of lines) {
                // Format 1: HDMI-A-2 tag 1 1 1 1
                // Parts: output, "tag", number, occupied, active, urgent
                const parts = line.split(/\s+/);
                
                if (parts.length >= 5 && parts[1] === "tag") {
                    const tagNum = parseInt(parts[2]);
                    const occupied = parts[3] === "1";
                    occupiedMap[tagNum] = occupied;
                }
                // Format 2: HDMI-A-2 tags 000000111 000000001 000000000
                // Bitfields: visible, focused, urgent
                else if (parts.length >= 4 && parts[1] === "tags") {
                    visibleTagMask = parts[2];
                    focusedTagMask = parts[3];
                    
                    // Find the focused tag (rightmost bit that is '1')
                    for (let i = focusedTagMask.length - 1; i >= 0; i--) {
                        if (focusedTagMask[i] === '1') {
                            const tagNum = focusedTagMask.length - i;
                            activeTagNumber = tagNum;
                            break;
                        }
                    }
                }
            }
            
            // Rebuild the tags array to trigger QML property updates
            const newTags = [];
            for (let i = 1; i <= 9; i++) {
                newTags.push({
                    id: i,
                    name: `tag ${i}`,
                    lastIpcObject: {
                        windows: occupiedMap[i] ? 1 : 0,
                        specialWorkspace: { name: "" }
                    },
                    monitor: focusedMonitor,
                    toplevels: { values: [] }
                });
            }
            parsedTags = newTags;
        } catch (e) {
            console.error("MangoWC: Error parsing tag state:", e);
        }
    }

    // Stub for toast notifications (removed keyboard-related toasts)
    onCapsLockChanged: {
        // MangoWC doesn't expose capslock state
    }

    onNumLockChanged: {
        // MangoWC doesn't expose numlock state
    }

    onKbLayoutFullChanged: {
        // MangoWC doesn't expose keyboard layout changes
    }

    // Remove Hyprland event connections
    // MangoWC doesn't have a similar event system

    IpcHandler {
        target: "mango"

        function refreshDevices(): void {
            // No-op for MangoWC
        }
    }

    CustomShortcut {
        name: "refreshDevices"
        description: "Reload devices"
        onPressed: {} // No-op for MangoWC
        onReleased: {} // No-op for MangoWC
    }
}
