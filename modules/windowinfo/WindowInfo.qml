import qs.components
import qs.services
import qs.config
import Quickshell
// import Quickshell.Hyprland  // Removed for MangoWC
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    required property var client  // Changed from HyprlandToplevel

    implicitWidth: child.implicitWidth
    implicitHeight: screen.height * Config.winfo.sizes.heightMult

    RowLayout {
        id: child

        anchors.fill: parent
        anchors.margins: Appearance.padding.large

        spacing: Appearance.spacing.normal

        Preview {
            screen: root.screen
            client: root.client
        }

        ColumnLayout {
            spacing: Appearance.spacing.normal

            Layout.preferredWidth: Config.winfo.sizes.detailsWidth
            Layout.fillHeight: true

            StyledRect {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: Colours.tPalette.m3surfaceContainer
                radius: Appearance.rounding.normal

                Details {
                    client: root.client
                }
            }

            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: buttons.implicitHeight

                color: Colours.tPalette.m3surfaceContainer
                radius: Appearance.rounding.normal

                Buttons {
                    id: buttons

                    client: root.client
                }
            }
        }
    }
}
