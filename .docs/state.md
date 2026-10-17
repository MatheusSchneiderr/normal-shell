# State

```
repo -> ~/.config (links)        panel -> prefs.json (own settings)
```

| Where | What | After a rebuild |
|---|---|---|
| this repo | code and scripts | kept (git) |
| `~/.config/wayfire.ini`, `quickshell/theme.json`, `quickshell/xkb-base.lst`, portal config | rendered by Nix | rewritten, do not edit |
| `~/.config/quickshell/prefs.json` | clock, do-not-disturb, wallpaper, fonts, color picks, keyboard layout, screenshot settings | kept, not in the repo |
| `~/.config/swappy/config` | the screenshot editor's save folder (written by the panel) | rewritten at each capture |
| `~/.config/mimeapps.list` | default apps | kept, not in the repo |
| `~/Pictures` | wallpapers | kept, not in the repo |
| NetworkManager, Bluetooth, WirePlumber, cliphist | their own data | kept, not ours |

Notification history lives in memory only, newest 50.

A reinstall or a new machine loses everything that is not in the repo.
