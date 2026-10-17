#!/usr/bin/env bash
# Smoke test: loads the real shell in a headless Wayfire, opens every popup and every Settings page,
# and fails on any QML warning or error. Nothing touches your session; power actions are dry-run.
# Usage: dev/smoke.sh [--shots DIR]     (DIR receives one PNG per popup/page)
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
qs="$(dirname "$here")"                                # quickshell
if [ "${1:-}" != "--inner" ]; then
  # private session bus so the notification service never fights your real mako/panel
  dbus-run-session -- "$0" --inner "$@" 2>&1 | grep -avE 'dbus-daemon|xdg-desktop-portal|discover_other_daemon|^$'
  exit "${PIPESTATUS[0]}"
fi
shift
shots=""; [ "${1:-}" = "--shots" ] && shots="${2:?}" && mkdir -p "$shots"

state="${XDG_RUNTIME_DIR:?}/qs-dev"
log="$state/smoke.log"
allowed='prefs\.json|theme\.json|Could not load icon|portal|xdg-desktop|Failed to register with host portal|secret|screen cast'

"$here/headless.sh" start >/dev/null || exit 1
# shellcheck disable=SC1091
source "$state/env"
trap '[ -n "${qspid:-}" ] && kill "$qspid" 2>/dev/null; "$here/headless.sh" stop >/dev/null' EXIT

export QS_PREFS="$state/prefs.json"
export QT_QUICK_BACKEND=software QS_DRYRUN=1 QS_WAYFIRE_SCRIPTS="$(dirname "$qs")/compositor"
[ -f "$HOME/.config/quickshell/theme.json" ] && export QS_THEME="$HOME/.config/quickshell/theme.json"
cd /tmp
quickshell -p "$qs" > "$log" 2>&1 &
qspid=$!
for _ in $(seq 40); do grep -q "Configuration Loaded\|Failed to load" "$log" && break; sleep 0.25; done
grep -q "Failed to load configuration" "$log" && { cat "$log"; echo "SMOKE FAILED: shell did not load"; exit 1; }
ipc() { quickshell -p "$qs" ipc call "$@" 2>&1; }
shot() { [ -n "$shots" ] && grim "$shots/$1.png" 2>/dev/null; true; }

fail=0
popups=$(ls "$qs"/modules/*/*Popup.qml | sed -E 's#.*/modules/([^/]+)/.*#\1#')
for p in $popups; do
  ipc popup toggle "$p" >/dev/null; sleep 2.5
  [ "$(ipc popup current)" = "$p" ] || { echo "FAIL popup $p did not open"; fail=1; }
  shot "popup-$p"; ipc popup toggle "$p" >/dev/null; sleep 0.4
done
pages=$(grep -oE 'id: "[a-z]+", label' "$qs/shell/SettingsWindow.qml" | sed -E 's/id: "([a-z]+)".*/\1/')
for g in $pages; do
  ipc settings open "$g" >/dev/null; sleep 3.5
  shot "page-$g"; ipc settings close >/dev/null; sleep 0.4
done
ipc start toggle >/dev/null; sleep 1.5; shot "start-menu"; ipc start toggle >/dev/null
ipc resize toggle >/dev/null; sleep 1.5; shot "resize-mode"; ipc resize stop >/dev/null
printf 'screen-a\nscreen-b\n' | QS_ARGS="-p $qs" "$qs/modules/screencast/portal-pick" > "$state/picked" 2>&1 &
sleep 2; shot "screen-picker"; ipc picker cancel >/dev/null; wait $! 2>/dev/null
[ -s "$state/picked" ] && { echo "FAIL screen picker returned text on cancel"; fail=1; }

bad=$(grep -aE "WARN|ERROR" "$log" | grep -avE "$allowed" || true)
if [ -n "$bad" ]; then echo "$bad"; fail=1; fi
[ $fail -eq 0 ] && echo "smoke: ok ($(echo $popups | wc -w) popups, $(echo $pages | wc -w) pages)" || echo "SMOKE FAILED"
exit $fail
