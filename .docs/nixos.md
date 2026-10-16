# NixOS and runtime changes

```
Settings -> change now -> NixOS config wins again later
```

On NixOS, `configuration.nix` is the truth. Settings can still change three things for now.

| Setting | How long it lasts |
|---|---|
| Time zone | until the next reboot or rebuild |
| Keyboard layout | re-applied each time the panel starts (saved in `prefs.json`) |
| Language and formats | until you log out |

To make any of them permanent, change `configuration.nix` and rebuild.

## Banner
On NixOS (`/etc/os-release` has `ID=nixos`) the Date & time page shows a warning.
The Language row shows only there too.

## Language, how it applies now
A program's language is fixed when it starts. So "apply" does two things:
- sets the new language for the user session (`systemctl --user set-environment`, D-Bus)
- restarts the panel with it

New programs from the start menu or launcher use it.
Open windows and programs started by key bindings keep the old language.

## Keyboard
`compositor/input.lua` sets the layout in Wayfire over IPC. It works live.
