//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import "modules"
import "modules/drawers"
import "modules/background"
import "modules/areapicker"
import "modules/lock"
import QtQuick
import Quickshell

ShellRoot {
    id: root

    settings.watchFiles: true
    readonly property bool toolingMode: Quickshell.env("CAELESTIA_QML_TOOLING") === "1"

    Loader {
        active: !root.toolingMode
        sourceComponent: Item {
            Background {}
            Drawers {}
            AreaPicker {}
            Lock {
                id: lock
            }

            Shortcuts {}
            BatteryMonitor {}
            IdleMonitors {
                lock: lock
            }
        }
    }
}
