pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string connectingToSsid: ""
    property string passwordDialogSsid: ""
    property bool showPasswordDialog: false

    spacing: Appearance.spacing.small
    width: Config.bar.sizes.networkWidth

    StyledText {
        Layout.topMargin: Appearance.padding.normal
        Layout.rightMargin: Appearance.padding.small
        text: qsTr("Wifi %1").arg(Network.wifiEnabled ? "enabled" : "disabled")
        font.weight: 500
    }

    Toggle {
        label: qsTr("Enabled")
        checked: Network.wifiEnabled
        toggle.onToggled: Network.enableWifi(checked)
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.small
        Layout.rightMargin: Appearance.padding.small
        text: qsTr("%1 networks available").arg(Network.networks.length)
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.small
    }

    Repeater {
        model: ScriptModel {
            values: [...Network.networks].sort((a, b) => {
                if (a.active !== b.active)
                    return b.active - a.active;
                return b.strength - a.strength;
            }).slice(0, 8)
        }

        RowLayout {
            id: networkItem

            required property Network.AccessPoint modelData
            readonly property bool isConnecting: root.connectingToSsid === modelData.ssid
            readonly property bool loading: networkItem.isConnecting

            Layout.fillWidth: true
            Layout.rightMargin: Appearance.padding.small
            spacing: Appearance.spacing.small

            opacity: 0
            scale: 0.7

            Component.onCompleted: {
                opacity = 1;
                scale = 1;
            }

            Behavior on opacity {
                Anim {}
            }

            Behavior on scale {
                Anim {}
            }

            MaterialIcon {
                text: Icons.getNetworkIcon(networkItem.modelData.strength)
                color: networkItem.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }

            MaterialIcon {
                visible: networkItem.modelData.isSecure
                text: "lock"
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                Layout.leftMargin: Appearance.spacing.small / 2
                Layout.rightMargin: Appearance.spacing.small / 2
                Layout.fillWidth: true
                text: networkItem.modelData.ssid
                elide: Text.ElideRight
                font.weight: networkItem.modelData.active ? 500 : 400
                color: networkItem.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
            }

            StyledRect {
                id: connectBtn

                implicitWidth: implicitHeight
                implicitHeight: connectIcon.implicitHeight + Appearance.padding.small

                radius: Appearance.rounding.full
                color: Qt.alpha(Colours.palette.m3primary, networkItem.modelData.active ? 1 : 0)

                CircularIndicator {
                    anchors.fill: parent
                    running: networkItem.loading
                }

                StateLayer {
                    color: networkItem.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    disabled: networkItem.loading || !Network.wifiEnabled

                    function onClicked(): void {
                        if (networkItem.modelData.active) {
                            Network.disconnectFromNetwork();
                        } else {
                            // Show password dialog for secure networks, connect directly for open networks
                            if (networkItem.modelData.isSecure) {
                                root.passwordDialogSsid = networkItem.modelData.ssid;
                                root.showPasswordDialog = true;
                            } else {
                                root.connectingToSsid = networkItem.modelData.ssid;
                                Network.connectToNetwork(networkItem.modelData.ssid, "");
                            }
                        }
                    }
                }

                MaterialIcon {
                    id: connectIcon

                    anchors.centerIn: parent
                    animate: true
                    text: networkItem.modelData.active ? "link_off" : "link"
                    color: networkItem.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

                    opacity: networkItem.loading ? 0 : 1

                    Behavior on opacity {
                        Anim {}
                    }
                }
            }
        }
    }

    StyledRect {
        Layout.topMargin: Appearance.spacing.small
        Layout.fillWidth: true
        implicitHeight: rescanBtn.implicitHeight + Appearance.padding.small * 2

        radius: Appearance.rounding.full
        color: Colours.palette.m3primaryContainer

        StateLayer {
            color: Colours.palette.m3onPrimaryContainer
            disabled: Network.scanning || !Network.wifiEnabled

            function onClicked(): void {
                Network.rescanWifi();
            }
        }

        RowLayout {
            id: rescanBtn

            anchors.centerIn: parent
            spacing: Appearance.spacing.small
            opacity: Network.scanning ? 0 : 1

            MaterialIcon {
                id: scanIcon

                animate: true
                text: "wifi_find"
                color: Colours.palette.m3onPrimaryContainer
            }

            StyledText {
                text: qsTr("Rescan networks")
                color: Colours.palette.m3onPrimaryContainer
            }

            Behavior on opacity {
                Anim {}
            }
        }

        CircularIndicator {
            anchors.centerIn: parent
            strokeWidth: Appearance.padding.small / 2
            bgColour: "transparent"
            implicitHeight: parent.implicitHeight - Appearance.padding.smaller * 2
            running: Network.scanning
        }
    }

    // Reset connecting state when network changes
    Connections {
        target: Network

        function onActiveChanged(): void {
            if (Network.active && root.connectingToSsid === Network.active.ssid) {
                root.connectingToSsid = "";
            }
        }

        function onScanningChanged(): void {
            if (!Network.scanning)
                scanIcon.rotation = 0;
        }
    }

    // Password dialog overlay
    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.normal
        implicitHeight: passwordColumn.implicitHeight + Appearance.padding.normal * 2
        visible: root.showPasswordDialog
        radius: Appearance.rounding.normal
        color: Colours.palette.m3surfaceContainerHighest

        ColumnLayout {
            id: passwordColumn

            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.normal

            StyledText {
                text: qsTr("Enter password for \"%1\"").arg(root.passwordDialogSsid)
                font.weight: 500
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            StyledTextField {
                id: passwordField

                Layout.fillWidth: true
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password

                onAccepted: {
                    root.connectingToSsid = root.passwordDialogSsid;
                    Network.connectToNetwork(root.passwordDialogSsid, text);
                    root.showPasswordDialog = false;
                    text = "";
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: cancelText.implicitHeight + Appearance.padding.small * 2
                    radius: Appearance.rounding.small
                    color: Colours.palette.m3surfaceContainerHigh

                    StateLayer {
                        color: Colours.palette.m3onSurface

                        function onClicked(): void {
                            root.showPasswordDialog = false;
                            passwordField.text = "";
                        }
                    }

                    StyledText {
                        id: cancelText

                        anchors.centerIn: parent
                        text: qsTr("Cancel")
                        color: Colours.palette.m3onSurface
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: connectText.implicitHeight + Appearance.padding.small * 2
                    radius: Appearance.rounding.small
                    color: Colours.palette.m3primary

                    StateLayer {
                        color: Colours.palette.m3onPrimary

                        function onClicked(): void {
                            root.connectingToSsid = root.passwordDialogSsid;
                            Network.connectToNetwork(root.passwordDialogSsid, passwordField.text);
                            root.showPasswordDialog = false;
                            passwordField.text = "";
                        }
                    }

                    StyledText {
                        id: connectText

                        anchors.centerIn: parent
                        text: qsTr("Connect")
                        color: Colours.palette.m3onPrimary
                        font.weight: 500
                    }
                }
            }
        }
    }

    component Toggle: RowLayout {
        required property string label
        property alias checked: toggle.checked
        property alias toggle: toggle

        Layout.fillWidth: true
        Layout.rightMargin: Appearance.padding.small
        spacing: Appearance.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: parent.label
        }

        StyledSwitch {
            id: toggle
        }
    }
}
