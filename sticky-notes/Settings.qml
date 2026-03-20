import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.UI
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  property var mainInstance: pluginApi?.mainInstance

  property bool valueSyncEnabled: cfg.syncEnabled ?? defaults.syncEnabled ?? false
  property string valueGithubToken: cfg.githubToken ?? defaults.githubToken ?? ""

  spacing: Style.marginL

  NToggle {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.syncEnabled.label") || "Enable GitHub Gist sync"
    description: pluginApi?.tr("settings.syncEnabled.desc") || "Automatically sync notes to a private gist after changes."
    checked: root.valueSyncEnabled
    onToggled: checked => root.valueSyncEnabled = checked
  }

  NTextInput {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.githubToken.label") || "GitHub Token"
    description: pluginApi?.tr("settings.githubToken.desc") || "Personal access token with gist permission."
    placeholderText: pluginApi?.tr("settings.githubToken.placeholder") || "ghp_xxx"
    text: root.valueGithubToken
    onTextChanged: root.valueGithubToken = text
  }

  NText {
    Layout.fillWidth: true
    text: pluginApi?.tr("settings.githubToken.help") || "The plugin creates or reuses a private gist named `noctalia-sticky-notes`. Each note is stored as one file whose filename is the note id."
    pointSize: Style.fontSizeS
    color: Color.mOnSurfaceVariant
    wrapMode: Text.Wrap
    textFormat: Text.MarkdownText
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: Style.marginM

    NButton {
      text: pluginApi?.tr("settings.syncNow") || "Sync now"
      icon: "refresh"
      enabled: !mainInstance?.syncInProgress
      onClicked: {
        root.saveSettings();
        if (mainInstance) {
          mainInstance.manualSync();
        }
      }
    }

    Item { Layout.fillWidth: true }

    NText {
      text: {
        if (mainInstance?.syncInProgress) {
          return pluginApi?.tr("sync.syncing") || "Syncing notes to GitHub Gist...";
        }
        return mainInstance?.lastSyncMessage || "";
      }
      color: mainInstance?.lastSyncOk ? Color.mPrimary : Color.mOnSurfaceVariant
      pointSize: Style.fontSizeS
      wrapMode: Text.Wrap
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignRight
    }
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("StickyNotes", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.syncEnabled = root.valueSyncEnabled;
    pluginApi.pluginSettings.githubToken = root.valueGithubToken.trim();
    pluginApi.saveSettings();

    Logger.i("StickyNotes", "Settings saved");
    ToastService.showNotice(pluginApi?.tr("settings.saved") || "Sticky Notes settings saved");
  }
}
