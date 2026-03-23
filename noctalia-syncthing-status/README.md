# noctalia-syncthing-status

Syncthing status plugin for Noctalia on Niri.

It adds a bar widget and panel that show whether Syncthing is idle, syncing, paused, disconnected, offline, unauthorized, or in an error state.

Developed by Pir0c0pter0 (`pir0c0pter0000@gmail.com`).

## Features

- Compact bar widget with a theme-aware main icon
- Status badge for sync state changes
- Detailed panel with device and folder summary
- Folder-level status, including paused and error states
- Automatic detection of Syncthing GUI URL, API key, and `config.xml`
- Automatic language mode that follows the system locale by default
- Manual override for URL, API key, TLS verification, polling interval, and monitored folders

## How It Works

The plugin uses a small Python helper, [`syncthing-status.py`](./syncthing-status.py), to query the Syncthing REST API and return a normalized JSON snapshot.

[`Main.qml`](./Main.qml) polls that helper periodically and shares the result with:

- the bar widget
- the plugin panel
- the settings page

## Requirements

- Noctalia `4.4.0` or newer
- A working Syncthing instance with the GUI API enabled
- Python 3 available in your environment

## Installation

1. Clone this repository.
2. Link the plugin into your Noctalia plugins directory:

```bash
ln -s /path/to/noctalia-syncthing-status ~/.config/noctalia/plugins/noctalia-syncthing-status
```

3. Enable the plugin in `~/.config/noctalia/plugins.json`.
4. Add `plugin:noctalia-syncthing-status` to your bar widgets in `~/.config/noctalia/settings.json`.
5. Restart Noctalia / Quickshell.

## Configuration

By default, the plugin tries to autodetect:

- `~/.local/state/syncthing/config.xml`
- `~/.config/syncthing/config.xml`
- Syncthing GUI URL
- Syncthing API key

You can still configure everything manually in the plugin settings if you want to target a different Syncthing instance.

Available settings:

- Enable or disable the plugin
- Syncthing GUI URL
- API key
- `config.xml` path
- TLS verification
- Poll interval
- Specific folders to monitor
- Language selection

Language defaults to `Auto`, which follows the current system locale.

## Status States

The plugin can report these high-level states:

- `idle`: monitored folders are synchronized
- `syncing`: one or more monitored folders are actively syncing or still have pending items
- `paused`: all monitored folders are paused
- `disconnected`: Syncthing is reachable, but no active remote device is connected
- `offline`: the GUI endpoint could not be reached
- `unauthorized`: the API key is invalid or missing
- `error`: one or more monitored folders reported an error
- `unconfigured`: no monitored folders are available

## Notes

- TLS verification is disabled by default to avoid breaking common local or self-signed Syncthing setups.
- If no folders are selected in the settings, the plugin monitors all available Syncthing folders.
- The bar icon follows the active Noctalia theme, while the small status badge changes according to the current state.

## Development

Project structure:

- [`manifest.json`](./manifest.json): plugin metadata and default settings
- [`Main.qml`](./Main.qml): state management, polling, translations, and helpers
- [`BarWidget.qml`](./BarWidget.qml): bar widget UI
- [`Panel.qml`](./Panel.qml): expanded panel UI
- [`Settings.qml`](./Settings.qml): plugin settings UI
- [`syncthing-status.py`](./syncthing-status.py): Syncthing API integration

## Troubleshooting

If the plugin shows `offline`:

- verify that the Syncthing GUI is running
- confirm the GUI URL is correct
- check whether local firewall rules are blocking access

If the plugin shows `unauthorized`:

- verify the API key
- confirm the selected `config.xml` belongs to the Syncthing instance you want to monitor

If the plugin shows `unconfigured`:

- verify that Syncthing has folders configured
- check whether you filtered the monitored folder list to an empty or invalid selection

## License

MIT. See [`LICENSE`](./LICENSE).
