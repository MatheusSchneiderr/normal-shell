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
- `services/`: logic without UI (commands, polling, saved settings)
- `shell/`: the frame (panel, popup host, start menu, Settings window)
- `modules/<feature>/`: one folder per feature (network, sound, battery...)

## Import rule
A module imports `components`, `services`, `Theme` and `Icons`. Never another module.
Only `shell/` and `shell.qml` import modules.

## Editing
- QML files are live. Save and the panel reloads.
- Files that Nix renders (`wayfire.ini`, `theme.json`) need a rebuild.

More: `quickshell/rules.md` (dev rules), `quickshell/dev/README.md` (testing).
