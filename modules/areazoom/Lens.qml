pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.effects
import qs.services

// Select a screen area, then magnify it in a floating live panel.
//
// Selection phase: the whole screen is dimmed with a crosshair cursor; drag a
// rectangle (or hover to snap to the window under the cursor and click it).
// Lens phase: a floating panel shows the selected region magnified live, with
// wheel/+/- zoom and a draggable header. Only the panel itself takes input, so
// the rest of the desktop stays usable while the zoom is open.
MouseArea {
    id: root

    required property LazyLoader loader
    required property ShellScreen screen

    readonly property bool selecting: loader.activeScreen === ""

    // Selected region (screen coordinates)
    property real ssx
    property real ssy
    property real sx
    property real sy
    property real ex
    property real ey

    readonly property real rsx: Math.min(sx, ex)
    readonly property real rsy: Math.min(sy, ey)
    readonly property real rw: Math.abs(sx - ex)
    readonly property real rh: Math.abs(sy - ey)

    // Magnifier state
    property real zoom: 2
    property real lensX: 0
    property real lensY: 0

    readonly property real headerHeight: 36
    readonly property int minRegionSize: 80
    readonly property int screenMargin: Tokens.padding.small
    readonly property real maxContentW: screen.width * 0.9
    // Keep the whole panel (content + header) within 90% of the screen
    readonly property real fitZoom: Math.min(maxContentW / rw, (screen.height * 0.9 - headerHeight) / rh)
    readonly property real maxZoom: Math.min(8, Math.max(fitZoom, 1))
    readonly property real magnification: Math.min(Math.max(zoom, 1), Math.max(fitZoom, 1))
    readonly property real lensW: rw * magnification
    readonly property real contentH: rh * magnification
    readonly property real lensH: contentH + headerHeight

    // The capture includes this window itself, so pause it while the panel
    // overlaps the sampled region to avoid a recursive feedback loop.
    readonly property bool lensOverSource: lensX < rsx + rw && lensX + lensW > rsx && lensY < rsy + rh && lensY + lensH > rsy

    property bool onClient
    property list<var> clients: {
        const mon = Hypr.monitorFor(screen);
        if (!mon)
            return [];

        const special = mon.lastIpcObject?.specialWorkspace;
        const wsId = special?.name ? special.id : mon.activeWorkspace?.id;
        if (wsId === undefined)
            return [];

        return Hypr.toplevels.values.filter(t => t.monitor === mon && t.lastIpcObject.visible);
    }

    function checkClientRects(x: real, y: real): void {
        for (const client of clients) {
            if (!client)
                continue;

            const ipc = client.lastIpcObject;
            if (!ipc?.at || !ipc?.size)
                continue;

            let {
                at: [cx, cy],
                size: [cw, ch]
            } = ipc;
            cx -= screen.x;
            cy -= screen.y;
            if (cx <= x && cy <= y && cx + cw >= x && cy + ch >= y) {
                onClient = true;
                sx = cx;
                sy = cy;
                ex = cx + cw;
                ey = cy + ch;
                break;
            }
        }
    }

    function setHoverRect(x: real, y: real): void {
        onClient = false;
        sx = x;
        sy = y;
        ex = x;
        ey = y;
        checkClientRects(x, y);
    }

    // Clamp a rect of the given size fully inside the screen.
    function clampPos(x: real, y: real, w: real, h: real): point {
        return Qt.point(Math.min(Math.max(screenMargin, x), Math.max(screenMargin, screen.width - screenMargin - w)), Math.min(Math.max(screenMargin, y), Math.max(screenMargin, screen.height - screenMargin - h)));
    }

    function reclampLens(): void {
        const pos = clampPos(lensX, lensY, lensW, lensH);
        lensX = pos.x;
        lensY = pos.y;
    }

    function zoomBy(factor: real): void {
        zoom = Math.min(Math.max(zoom * factor, 1), maxZoom);
        reclampLens();
    }

    // Place the panel next to the selected region, falling back to
    // below/above when there is no room on either side.
    function placeLens(): void {
        const gap = Tokens.padding.large;
        let x = rsx + rw + gap;
        if (x + lensW > screen.width - screenMargin)
            x = rsx - gap - lensW;

        if (x >= screenMargin) {
            lensX = x;
            lensY = clampPos(lensX, rsy + rh / 2 - lensH / 2, lensW, lensH).y;
        } else {
            const below = clampPos(rsx + rw / 2 - lensW / 2, rsy + rh + gap, lensW, lensH);
            if (below.y > rsy + rh) {
                lensX = below.x;
                lensY = below.y;
            } else {
                const above = clampPos(rsx + rw / 2 - lensW / 2, rsy - gap - lensH, lensW, lensH);
                lensX = above.x;
                lensY = above.y;
            }
        }
    }

    function completeSelection(): void {
        // Click without a drag: magnify the window under the cursor or a
        // default-sized box around it.
        if (rw < 6 || rh < 6)
            setHoverRect(ssx, ssy);

        // Enforce a minimum region size around the selection centre
        const cx = rsx + rw / 2;
        const cy = rsy + rh / 2;
        if (rw < minRegionSize) {
            sx = cx - minRegionSize / 2;
            ex = cx + minRegionSize / 2;
        }
        if (rh < minRegionSize) {
            sy = cy - minRegionSize / 2;
            ey = cy + minRegionSize / 2;
        }

        zoom = Math.min(Math.max(zoom, 1), maxZoom);
        placeLens();
        loader.activeScreen = screen.name;
        loader.activeLens = root;
    }

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: selecting ? Qt.CrossCursor : Qt.ArrowCursor
    opacity: loader.closing ? 0 : 1

    Component.onCompleted: {
        const center = clampPos(screen.width / 2 - 150, screen.height / 2 - 100, 300, 200);
        sx = center.x;
        sy = center.y;
        ex = center.x + 300;
        ey = center.y + 200;

        cursorQuery.running = true;
    }

    onPressed: event => {
        ssx = event.x;
        ssy = event.y;
        onClient = false;
        sx = ssx;
        sy = ssy;
        ex = ssx;
        ey = ssy;
    }

    onReleased: {
        if (loader.closing)
            return;
        completeSelection();
    }

    onPositionChanged: event => {
        if (selecting && pressed) {
            sx = ssx;
            sy = ssy;
            ex = event.x;
            ey = event.y;
        } else if (selecting) {
            setHoverRect(event.x, event.y);
        }
    }

    onWheel: event => {
        if (selecting || loader.closing)
            return;

        zoomBy(event.angleDelta.y > 0 ? 1.25 : 0.8);
        event.accepted = true;
    }

    focus: true
    Keys.onEscapePressed: loader.close()
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Plus || event.key === Qt.Key_Equal)
            zoomBy(1.25);
        else if (event.key === Qt.Key_Minus)
            zoomBy(0.8);
    }

    Process {
        id: cursorQuery

        running: false
        command: ["mmsg", "get", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const pos = JSON.parse(text);
                    if (root.selecting && pos && typeof pos.x === "number" && typeof pos.y === "number" && pos.monitor === root.screen.name)
                        root.setHoverRect(pos.x - root.screen.x, pos.y - root.screen.y);
                } catch (e) {
                    console.warn("Failed to parse cursorpos:", e);
                }
            }
        }
    }

    // Input masks for the hosting window.
    Region {
        id: emptyMask
    }

    Region {
        id: lensMask

        // Tokens is not screen-scoped inside a Region, so use the literal value
        x: root.lensX - 8
        y: root.lensY - 8
        width: root.lensW + 16
        height: root.lensH + 16
    }

    readonly property alias emptyMaskRegion: emptyMask
    readonly property alias lensMaskRegion: lensMask

    // --- Selection phase visuals ---

    StyledRect {
        visible: root.selecting
        anchors.fill: parent
        color: Colours.palette.m3secondaryContainer
        opacity: 0.3

        layer.enabled: true
        layer.effect: Mask {
            maskSource: selectionWrapper
            maskInverted: true
        }
    }

    Item {
        id: selectionWrapper

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            x: root.rsx
            y: root.rsy
            implicitWidth: root.rw
            implicitHeight: root.rh
        }
    }

    Rectangle {
        visible: root.selecting
        color: "transparent"
        border.width: 2
        border.color: Colours.palette.m3primary

        x: root.rsx - 2
        y: root.rsy - 2
        implicitWidth: root.rw + 4
        implicitHeight: root.rh + 4

        Behavior on border.color {
            CAnim {}
        }
    }

    StyledRect {
        visible: root.selecting
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Tokens.padding.large

        implicitWidth: hintRow.implicitWidth + Tokens.padding.large * 2
        implicitHeight: hintRow.implicitHeight + Tokens.padding.small * 2

        radius: Tokens.rounding.full
        color: Colours.palette.m3surfaceContainer

        Row {
            id: hintRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "drag_pan"
                color: Colours.palette.m3onSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: Tr.tr("Drag an area to magnify, or click a window")
                color: Colours.palette.m3onSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // --- Lens panel ---

    Elevation {
        level: 3
        radius: Tokens.rounding.large
        opacity: lensBody.opacity
        visible: lensBody.visible
        x: root.lensX
        y: root.lensY
        implicitWidth: root.lensW
        implicitHeight: root.lensH
    }

    Item {
        id: lensBody

        x: root.lensX
        y: root.lensY
        implicitWidth: root.lensW
        implicitHeight: root.lensH
        visible: !root.selecting
        opacity: visible ? 1 : 0

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }

        layer.enabled: true
        layer.effect: Mask {
            maskSource: bodyMask
        }

        Rectangle {
            id: bodyMask

            anchors.fill: parent
            radius: Tokens.rounding.large
            layer.enabled: true
            visible: false
        }

        StyledRect {
            anchors.fill: parent
            color: Colours.palette.m3surfaceContainer
        }

        // Magnified live content of the selected region. The capture is
        // mapped so the region's top-left lands exactly on the content area.
        Item {
            id: content

            y: root.headerHeight
            implicitWidth: root.lensW
            implicitHeight: root.contentH

            Loader {
                id: captureLoader

                asynchronous: true
                anchors.fill: parent
                active: lensBody.visible && !root.lensOverSource && !root.loader.closing

                sourceComponent: Item {
                    ScreencopyView {
                        id: capture

                        captureSource: root.screen
                        x: -root.rsx * root.magnification
                        y: -root.rsy * root.magnification
                        width: root.screen.width * root.magnification
                        height: root.screen.height * root.magnification
                    }

                    // The view only requests the next capture when it repaints,
                    // so drive it explicitly to keep the stream live.
                    FrameAnimation {
                        running: captureLoader.active
                        onTriggered: capture.captureFrame()
                    }
                }
            }

            StyledRect {
                visible: root.lensOverSource
                anchors.centerIn: parent
                implicitWidth: pausedRow.implicitWidth + Tokens.padding.large * 2
                implicitHeight: pausedRow.implicitHeight + Tokens.padding.small * 2

                radius: Tokens.rounding.full
                color: Colours.palette.m3surfaceContainer

                Row {
                    id: pausedRow

                    anchors.centerIn: parent
                    spacing: Tokens.spacing.small

                    MaterialIcon {
                        text: "pause"
                        color: Colours.palette.m3onSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: Tr.tr("Move the panel away to resume")
                        color: Colours.palette.m3onSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // Header: drag to move the panel
        MouseArea {
            id: header

            property point pressOrigin
            property point panelOrigin

            implicitWidth: root.lensW
            implicitHeight: root.headerHeight
            cursorShape: Qt.SizeAllCursor
            hoverEnabled: true

            onPressed: event => {
                pressOrigin = Qt.point(event.x, event.y);
                panelOrigin = Qt.point(root.lensX, root.lensY);
            }

            onPositionChanged: event => {
                if (!pressed)
                    return;
                const pos = root.clampPos(panelOrigin.x + event.x - pressOrigin.x, panelOrigin.y + event.y - pressOrigin.y, root.lensW, root.lensH);
                root.lensX = pos.x;
                root.lensY = pos.y;
            }

            StyledRect {
                anchors.fill: parent
                color: Colours.palette.m3surfaceContainerHigh
            }

            MaterialIcon {
                text: "zoom_in"
                color: Colours.palette.m3primary
                anchors.left: parent.left
                anchors.leftMargin: Tokens.padding.small
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: Tr.tr("Area zoom")
                color: Colours.palette.m3onSurface
                anchors.left: parent.left
                anchors.leftMargin: Tokens.padding.largeIncreased
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: `${Math.round(root.magnification * 100)}%`
                color: Colours.palette.m3onSurfaceVariant
                anchors.right: closeButton.left
                anchors.rightMargin: Tokens.spacing.largeIncreased
                anchors.verticalCenter: parent.verticalCenter
            }

            StateLayer {
                id: closeButton

                anchors.right: parent.right
                anchors.rightMargin: Tokens.spacing.small
                anchors.verticalCenter: parent.verticalCenter

                implicitWidth: Tokens.padding.extraLargeIncreased
                implicitHeight: implicitWidth

                radius: Tokens.rounding.full
                color: Colours.palette.m3onSurface

                MaterialIcon {
                    text: "close"
                    color: Colours.palette.m3onSurface
                    anchors.centerIn: parent
                }

                onClicked: root.loader.close()
            }
        }
    }

    Behavior on opacity {
        Anim {
            type: Anim.StandardLarge
        }
    }
}
