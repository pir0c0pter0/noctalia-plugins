import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Services.UI

import "utils/gistSync.js" as GistSync

Item {
  id: root

  property var pluginApi: null
  property bool syncInProgress: false
  property bool lastSyncOk: false
  property string lastSyncMessage: ""
  property double lastSyncAt: 0

  function withCurrentScreen(callback) {
    if (!pluginApi) {
      Logger.w("StickyNotes", "Plugin API not available for IPC request");
      return;
    }

    pluginApi.withCurrentScreen(function(screen) {
      if (!screen) {
        Logger.w("StickyNotes", "No active screen available for IPC request");
        return;
      }

      callback(screen);
    });
  }

  function loadStoredNotes() {
    if (!pluginApi)
      return [];

    var stored = pluginApi.pluginSettings.notes;
    if (!stored || stored.length === 0)
      return [];

    try {
      var parsed = JSON.parse(stored);
      return Array.isArray(parsed) ? parsed : [];
    } catch (e) {
      Logger.e("StickyNotes", "Failed to parse notes for sync: " + e);
      return [];
    }
  }

  function hasSyncToken() {
    if (!pluginApi || !pluginApi.pluginSettings) {
      return false;
    }

    return ((pluginApi.pluginSettings.githubToken || "").trim().length > 0);
  }

  function syncNotesToGist(notes, silent) {
    if (!pluginApi) {
      return;
    }

    if (syncInProgress) {
      Logger.w("StickyNotes", "Sync skipped because another sync is already running");
      return;
    }

    var syncEnabled = pluginApi.pluginSettings.syncEnabled === true;
    if (!syncEnabled && silent !== false) {
      return;
    }

    if (!hasSyncToken()) {
      lastSyncOk = false;
      lastSyncMessage = pluginApi.tr("sync.errors.missing-token") || "GitHub token is required before syncing.";
      lastSyncAt = Date.now();

      if (silent === true) {
        Logger.w("StickyNotes", "Auto sync skipped because GitHub token is empty");
        return;
      }
    }

    var syncNotes = notes;
    if (!Array.isArray(syncNotes)) {
      syncNotes = loadStoredNotes();
    }

    syncInProgress = true;
    lastSyncMessage = pluginApi.tr("sync.syncing") || "Syncing notes to GitHub Gist...";

    GistSync.syncNotes(pluginApi, syncNotes, function(success, message) {
      syncInProgress = false;
      lastSyncOk = success;
      lastSyncMessage = message || (success ? "Sync completed" : "Sync failed");
      lastSyncAt = Date.now();

      if (success) {
        Logger.i("StickyNotes", lastSyncMessage);
        if (silent !== true) {
          ToastService.showNotice(lastSyncMessage);
        }
      } else {
        Logger.e("StickyNotes", lastSyncMessage);
        ToastService.showError(lastSyncMessage);
      }
    });
  }

  function manualSync() {
    syncNotesToGist(loadStoredNotes(), false);
  }

  IpcHandler {
    target: "plugin:sticky-notes"

    function toggle() {
      root.withCurrentScreen(function(screen) {
        root.pluginApi.togglePanel(screen);
      });
    }
  }
}
