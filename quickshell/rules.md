# Quickshell panel

Entry point: `shell.qml`. The whole folder is symlinked to `~/.config/quickshell/panel`, so edits go live and new files need no rebuild. Colours and font come from `theme.json`.

Before you finish:
- Run `./check.sh`: static rules
- Run `dev/smoke.sh`: loads everything in a headless Wayfire and fails on any QML warning
- Check `../.docs/` on every implementation and update what the change touches. A new role group gets its own short doc.

## Where a file goes
- Generic UI piece (button, toggle, field): `components/`
- All logic, no UI (state, commands, polling, D-Bus, IPC): `services/`, whoever uses it
- One feature's screens (tray button, popup, page): `modules/<feature>/`
- The frame (panel, popup host, start menu, settings window): `shell/`

## Rules
1. Don't style raw `Text`/`TextInput` in modules. Use `Label`, `Glyph`, `TextField`, `Clickable`.
2. A module imports only `components/`, `services/`, `Theme` and `Icons`, never another module.
3. No hex colours, pixel numbers or `\uXXXX` icons outside `Theme.qml` and `Icons.qml`.
4. Run commands with `Cmd`, not `Process`. Only the Pager streams, so it is the exception.
5. A feature's popup and its Settings page share parts (`WifiList`, `DeviceRow`). Don't copy blocks between files.
6. Imports: `import qs` (Theme, Icons), `import qs.components`, `import qs.services`. Only `shell/` and `shell.qml` import `qs.modules.*`.
7. A color token belongs to one kind of element: `text*` on `Label`, `icon*` on `Glyph`, `fill*`/`line*` on shapes (knobs use `textBody` and `textPrimary`). `selected`, `danger`, `warning` and `success` fit any kind. `./check.sh` enforces it.
8. Gotchas: a file that imports `Quickshell.Io` can't use `Toggle`. Don't name a type `Region` or `State`, or an IPC function `show` or `call` (they clash with `quickshell ipc` subcommands). To center an icon in a button use `Glyph { centered: true }`, not `anchors.centerIn` (icons end up a few pixels off).

## Conventions
- Module files: `<Name>Tray`, `<Name>Popup`, `<Name>Page`. Its logic is `services/<Name>.qml`.
- Popup name = lowercase module folder (`ipc call popup toggle network`). `PopupHost` loads `modules/<name>/<Name>Popup.qml`.
- Tray button for a popup: `StatusButton { popup: "network" }`.
- A service that polls uses `Poller` and has `hold()`/`release()`; the popup or page calls them.
- `Panel.qml` and `SettingsWindow.qml` list tray buttons and pages by hand, in display order.
- A long-lived service must not keep per-event data forever: cap it or prune it (notifications keep the newest 50).
- State lives in `services/`. `services/Ui.qml` is only navigation (popup, start menu, settings).

## New feature
Run `./new-module.sh <name>`, then add the two lines it prints. Put its state and commands in `services/<Name>.qml`.
