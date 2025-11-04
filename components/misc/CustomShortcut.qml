// import Quickshell.Hyprland  // Disabled for MangoWC - no global shortcuts support
import QtQuick

// Stub for GlobalShortcut (MangoWC doesn't have this feature)
QtObject {
    property string appid: "caelestia"
    property string name: ""
    property string description: ""
    signal pressed()
    signal released()
}
