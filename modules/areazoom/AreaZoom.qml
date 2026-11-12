pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Caelestia.Config
import qs.components.containers
import qs.components.misc
import qs.services

Scope {
    id: root

    LazyLoader {
        id: zoomLoader

        property bool closing
        property string activeScreen
        property var activeLens: null

        function close(): void {
            if (zoomLoader.activeAsync && !zoomLoader.closing)
                zoomLoader.closing = true;
        }

        Variants {
            model: Screens.screens

            StyledWindow {
                id: win

                required property ShellScreen modelData

                screen: modelData
                name: "area-zoom"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: zoomLoader.closing ? WlrKeyboardFocus.None : (zoomLoader.activeScreen === "" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)
                visible: zoomLoader.activeScreen === "" || zoomLoader.activeScreen === modelData.name
                mask: {
                    if (zoomLoader.closing)
                        return lens.emptyMaskRegion;
                    // Selection phase: the window captures all input
                    return lens.selecting ? null : lens.lensMaskRegion;
                }

                anchors.top: true
                anchors.bottom: true
                anchors.left: true
                anchors.right: true

                Lens {
                    id: lens

                    loader: zoomLoader
                    screen: win.modelData
                }
            }
        }
    }

    Timer {
        running: zoomLoader.closing
        interval: Tokens.anim.durations.large + 100
        onTriggered: {
            if (!zoomLoader.closing)
                return;
            zoomLoader.activeAsync = false;
            zoomLoader.closing = false;
            zoomLoader.activeScreen = "";
            zoomLoader.activeLens = null;
        }
    }

    IpcHandler {
        target: "areazoom"

        function open(): void {
            zoomLoader.closing = false;
            zoomLoader.activeScreen = "";
            zoomLoader.activeAsync = true;
        }

        function close(): void {
            zoomLoader.close();
        }

        function toggle(): void {
            if (zoomLoader.activeAsync && !zoomLoader.closing)
                zoomLoader.close();
            else
                open();
        }

        function isOpen(): bool {
            return zoomLoader.activeAsync && !zoomLoader.closing;
        }

        function setZoom(zoom: real): void {
            const lens = zoomLoader.activeLens;
            if (!lens)
                return;
            lens.zoom = Math.min(Math.max(zoom, 1), lens.maxZoom);
            lens.reclampLens();
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "areaZoom"
        description: "Zoom into a screen area"
        onPressed: {
            if (zoomLoader.activeAsync && !zoomLoader.closing)
                zoomLoader.close();
            else {
                zoomLoader.closing = false;
                zoomLoader.activeScreen = "";
                zoomLoader.activeAsync = true;
            }
        }
    }
}
