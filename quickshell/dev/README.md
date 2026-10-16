# dev

- `dev/smoke.sh [--shots DIR]`: boots the shell in a headless Wayfire, opens every popup and Settings page, and fails on any QML warning. It is safe to run: power actions do nothing and your real session is not touched.
- `dev/headless.sh start|stop|env`: just the test compositor. Run `source <(dev/headless.sh env)`, then `quickshell -p .` or `grim` against it.

Lock screen: set `QS_LOCK_PAM` and `QS_LOCK_PAMDIR` to a test PAM file, and lock only inside the headless session.
Keys: send them with `stipc/feed_key` through `compositor/wfipc.lua`. Source the env first so you never talk to your real Wayfire.
Settings file: the panel's saved settings (clock format, do-not-disturb) are in `~/.config/quickshell/prefs.json`. `dev/smoke.sh` points `QS_PREFS` at a throwaway file, so tests never touch yours.
