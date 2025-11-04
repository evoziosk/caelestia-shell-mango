pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.services
import qs.config
import qs.modules.bar
import Quickshell
import Quickshell.Wayland
// import Quickshell.Hyprland  // Removed for MangoWC
import QtQuick
import QtQuick.Effects

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        StyledWindow {
            id: win

            readonly property bool hasFullscreen: Hypr.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false
            readonly property int dragMaskPadding: {
                // Always return 0 when panels are open or focus is active
                if (focusGrab.active || panels.popouts.isDetached)
                    return 0;

                // Always return 0 when there are windows (we'll rely on panel regions for hover)
                const mon = Hypr.monitorFor(screen);
                if (mon?.lastIpcObject.specialWorkspace.name || mon?.activeWorkspace?.lastIpcObject.windows > 0)
                    return 0;

                // When workspace is empty, use drag thresholds for hover activation
                const thresholds = [];
                for (const panel of ["dashboard", "launcher", "session", "sidebar"])
                    if (Config[panel].enabled)
                        thresholds.push(Config[panel].dragThreshold);
                return Math.max(...thresholds);
            }

            onHasFullscreenChanged: {
                visibilities.launcher = false;
                visibilities.session = false;
                visibilities.dashboard = false;
            }

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.session ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            mask: Region {
                // Capture bar + minimal edge strips for hover
                x: bar.implicitWidth
                y: Config.border.thickness  
                width: win.width - bar.implicitWidth - Config.border.thickness
                height: win.height - Config.border.thickness * 2
                intersection: Intersection.Xor

                regions: panelRegions.instances
            }

            Variants {
                id: panelRegions

                model: panels.children

                Region {
                    required property Item modelData

                    x: bar.implicitWidth + modelData.x
                    y: Config.border.thickness + modelData.y
                    width: modelData.visible ? Math.max(0, modelData.width) : 0
                    height: modelData.visible ? Math.max(0, modelData.height) : 0
                    intersection: Intersection.Subtract
                }
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Item {
                id: focusGrab

                property bool active: (visibilities.launcher && Config.launcher.enabled) || (visibilities.session && Config.session.enabled) || (visibilities.sidebar && Config.sidebar.enabled) || (!Config.dashboard.showOnHover && visibilities.dashboard && Config.dashboard.enabled) || (panels.popouts.currentName.startsWith("traymenu") && panels.popouts.current?.depth > 1)
                // property var windows: [win]  // Not used in MangoWC
                signal cleared()
                
                // Manual close on click outside would need to be implemented differently for MangoWC
            }

            StyledRect {
                anchors.fill: parent
                opacity: visibilities.session && Config.session.enabled ? 0.5 : 0
                color: Colours.palette.m3scrim

                Behavior on opacity {
                    Anim {}
                }
            }

            Item {
                anchors.fill: parent
                opacity: Colours.transparency.enabled ? Colours.transparency.base : 1
                layer.enabled: false  // Disable blur effect for crisp panels

                Border {
                    bar: bar
                }

                Backgrounds {
                    panels: panels
                    bar: bar
                }
            }

            PersistentProperties {
                id: visibilities

                property bool bar
                property bool osd
                property bool session
                property bool launcher
                property bool dashboard
                property bool utilities
                property bool sidebar

                Component.onCompleted: Visibilities.load(scope.modelData, this)
            }

            Interactions {
                screen: scope.modelData
                popouts: panels.popouts
                visibilities: visibilities
                panels: panels
                bar: bar

                Panels {
                    id: panels

                    screen: scope.modelData
                    visibilities: visibilities
                    bar: bar
                }

                BarWrapper {
                    id: bar

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    screen: scope.modelData
                    visibilities: visibilities
                    popouts: panels.popouts

                    Component.onCompleted: Visibilities.bars.set(scope.modelData, this)
                }
            }
        }
    }
}
