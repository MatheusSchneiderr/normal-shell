# Architecture

```
login -> wayfire -> panel (quickshell)
            ^            |
            '-- IPC (Lua scripts) --'
```

Wayfire is the compositor. Quickshell runs our panel: bar, start menu, popups, Settings, lock screen, notifications.

Nix only links files and starts services. The logic is plain files.

## Folders (`quickshell/`)
- `components/`: generic UI pieces (button, toggle, field)
- `services/`: all logic, no UI (state, commands, polling, D-Bus, IPC), whoever uses it
- `modules/<feature>/`: the screens of a feature (tray button, popup, page), built from components and services
- `shell/`: the frame (panel, popup host, start menu, Settings window)

## Import rule
A module imports `components`, `services`, `Theme` and `Icons`. Never another module.
Only `shell/` and `shell.qml` import modules.

## Editing
- QML files are live. Save and the panel reloads.
- Files that Nix renders (`wayfire.ini`, `theme.json`) need a rebuild.

More: `quickshell/rules.md` (dev rules), `quickshell/dev/README.md` (testing).
