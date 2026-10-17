# Screenshots

```
Print -> panel -> slurp (area) -> grim -> file + clipboard -> toast -> swappy (edit)
```

`Print` captures an area. `Super+Print` captures the whole screen.

Every capture is saved as `Screenshot_date-time.png` and copied to the clipboard. A notification shows the path.

The editor (swappy) opens next. Saving there adds a copy ending in `-edited`, in the same folder.

## Settings
Settings > Screenshots:
- the folder (default `~/Pictures/Screenshots`)
- copy to the clipboard: on or off
- open the editor: on or off

They are saved in `prefs.json`.

## Notes
- The keys call the panel: `quickshell -c panel ipc call screenshot region|full`.
- The panel writes `~/.config/swappy/config` so the editor saves to the same folder.
- `slurp` waits for regions on stdin, so the panel starts it with stdin from `/dev/null`.
