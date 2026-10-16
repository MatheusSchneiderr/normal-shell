# Compositor

```
wayfire.ini (Nix) + Lua scripts -> Wayfire <-IPC-> panel
```

## Config
`compositor/wayfire.ini` is rendered by Nix. A key change needs a rebuild.

## Lua scripts
They live in `compositor/` and are linked to `~/.config/wayfire/`.
- `edge-focus.lua`: focus and send windows, workspace at the edge
- `window.lua`: move, resize, pin
- `workspace-watch.lua`: feeds the pager
- `theme.lua`: title-bar colors (see `theming.md`)
- `input.lua`: keyboard layout (see `nixos.md`)
- `wfipc.lua`: the shared IPC helper

## IPC
Socket: `$XDG_RUNTIME_DIR/wayfire-$WAYLAND_DISPLAY-.socket`.
A message is a 4-byte little-endian length, then JSON.

## Gotchas
- `wayfire/set-config-options` is plural. The singular does not exist.
- `wm-actions` calls need `view_id`, with an underscore.
- JSON `null` means no focused window. `wfipc.lua` turns it into `nil`.
- Autostart entries run in parallel. So `0_session` chains the setup, then starts the session target.

## Keys call the panel
`quickshell -c panel ipc call <target> <function>`
