#!/usr/bin/env bash
# Safe test compositor: a headless Wayfire that never touches your real session.
# Usage: dev/headless.sh start|stop|env      (env prints WAYLAND_DISPLAY / WAYFIRE_SOCKET exports)
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"          # repo root
ini="$root/compositor/wayfire.ini"
state="${XDG_RUNTIME_DIR:?}/qs-dev"
mkdir -p "$state"

case "${1:-}" in
start)
  [ -f "$state/wayfire.pid" ] && kill -0 "$(cat "$state/wayfire.pid")" 2>/dev/null && { echo "already running"; exit 0; }
  # test config = repo wayfire.ini without [autostart] (so it never starts your real session target) plus stipc (key injection)
  awk '/^\[autostart\]/{skip=1; next} /^\[/{skip=0} !skip' "$ini" | sed 's/^plugins = \\$/plugins = \\\n  stipc \\/' > "$state/wayfire.ini"
  before=$(ls "$XDG_RUNTIME_DIR" | grep -E '^wayland-[0-9]+$' || true)
  WLR_BACKENDS=headless WLR_HEADLESS_OUTPUTS=1 WLR_RENDERER=pixman \
    setsid wayfire -c "$state/wayfire.ini" > "$state/wayfire.log" 2>&1 &
  echo $! > "$state/wayfire.pid"
  for _ in $(seq 40); do
    sleep 0.25
    new=$(comm -13 <(echo "$before" | sort) <(ls "$XDG_RUNTIME_DIR" | grep -E '^wayland-[0-9]+$' | sort) | head -1)
    [ -n "$new" ] && break
  done
  [ -n "${new:-}" ] || { echo "headless wayfire did not start, see $state/wayfire.log"; exit 1; }
  printf 'export WAYLAND_DISPLAY=%s\nexport WAYFIRE_SOCKET=%s/wayfire-%s-.socket\n' "$new" "$XDG_RUNTIME_DIR" "$new" > "$state/env"
  echo "started on $new"
  ;;
stop)
  [ -f "$state/wayfire.pid" ] && kill "$(cat "$state/wayfire.pid")" 2>/dev/null || true
  rm -f "$state/wayfire.pid" "$state/env"
  echo "stopped"
  ;;
env)
  cat "$state/env"
  ;;
*)
  echo "usage: dev/headless.sh start|stop|env"; exit 2
  ;;
esac
