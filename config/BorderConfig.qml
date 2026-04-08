import Quickshell.Io
import qs.config

JsonObject {
    property int thickness: 0  // Set to 0 to disable the border completely
    property int rounding: Config.appearance.rounding.large

    readonly property int minThickness: 2
    readonly property int clampedThickness: Math.max(minThickness, thickness)
}
