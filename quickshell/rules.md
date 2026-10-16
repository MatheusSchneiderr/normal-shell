# Quickshell panel

Entry point: `shell.qml`. The whole folder is symlinked to `~/.config/quickshell/panel`, so edits go live and new files need no rebuild. Colours and font come from `theme.json`.

Before you finish:
- Run `./check.sh`: static rules
- Run `dev/smoke.sh`: loads everything in a headless Wayfire and fails on any QML warning
- Check `../.docs/` on every implementation and update what the change touches. A new role group gets its own short doc.

## Where a file goes
- Generic UI piece (button, toggle, field): `components/`
- One feature (Wi-Fi, sound, lock...): `modules/<feature>/`
- The frame (panel, popup host, start menu, settings window): `shell/`
- Shared logic with no UI: `services/`

## Rules
1. Don't style raw `Text`/`TextInput` in modules. Use `Label`, `Glyph`, `TextField`, `Clickable`.
2. A module imports only `components/`, `services/`, `Theme` and `Icons`, never another module. If two modules need the same thing, move it to `services/`.
3. No hex colours, pixel numbers or `\uXXXX` icons outside `Theme.qml` and `Icons.qml`.
4. Run commands with `Cmd`, not `Process`. Only the Pager streams, so it is the exception.
5. A feature's popup and its Settings page share parts (`WifiList`, `DeviceRow`). Don't copy blocks between files.
6. Imports: `import qs` (Theme, Icons), `import qs.components`, `import qs.services`. Only `shell/` and `shell.qml` import `qs.modules.*`.
7. Gotchas: a file that imports `Quickshell.Io` can't use `Toggle`. Don't name a type `Region` or `State`, or an IPC function `show` or `call` (they clash with `quickshell ipc` subcommands).

## Conventions
- Module files: `<Name>Tray`, `<Name>Popup`, `<Name>Page`, and `<Name>` for a service.
- Popup name = lowercase module folder (`ipc call popup toggle network`). `PopupHost` loads `modules/<name>/<Name>Popup.qml`.
- Tray button for a popup: `StatusButton { popup: "network" }`.
- A service that polls uses `Poller` and has `hold()`/`release()`; the popup or page calls them.
- `Panel.qml` and `SettingsWindow.qml` list tray buttons and pages by hand, in display order.
- A long-lived service must not keep per-event data forever: cap it or prune it (notifications keep the newest 50).
- Feature state lives in the feature. `services/Ui.qml` is only navigation (popup, start menu, settings).

## New feature
Run `./new-module.sh <name>`, then add the two lines it prints.
