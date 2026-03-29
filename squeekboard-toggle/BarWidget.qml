import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    readonly property var mainInstance: pluginApi?.mainInstance
    property bool keyboardActive: mainInstance?.keyboardActive ?? false

    readonly property string barPosition: Settings.getBarPositionForScreen(screen ? screen.name : "")
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"

    readonly property real contentWidth: isVertical ? Style.capsuleHeight : Math.round(icon.implicitWidth + Style.marginM * 2)
    readonly property real contentHeight: isVertical ? Math.round(icon.implicitHeight + Style.marginM * 2) : Style.capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        radius: Style.radiusM
        color: Style.capsuleColor
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        NIcon {
            id: icon
            anchors.centerIn: parent
            icon: root.keyboardActive ? "keyboard" : "keyboard-off"
            color: root.keyboardActive ? Color.mPrimary : Color.mOnSurfaceVariant
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                mainInstance?.toggleKeyboard();
            } else if (mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, screen);
            }
        }

        onEntered: {
            TooltipService.show(root, root.keyboardActive ? pluginApi?.tr("tooltip.active") : pluginApi?.tr("tooltip.hidden"), BarService.getTooltipDirection());
        }
        onExited: TooltipService.hide()
    }

    NPopupContextMenu {
        id: contextMenu

        model: [
            {
                "label": pluginApi?.tr("menu.settings"),
                "action": "widget-settings",
                "icon": "settings"
            },
        ]

        onTriggered: action => {
            contextMenu.close();
            PanelService.closeContextMenu(screen);
            if (action === "widget-settings") {
                BarService.openPluginSettings(screen, pluginApi.manifest);
            }
        }
    }
}
