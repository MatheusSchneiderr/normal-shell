#!/usr/bin/env lua
-- Move or resize the most recently focused window from the keyboard.
--   window.lua move   <h|j|k|l|left|down|up|right> [pixels]   (default 40)
--   window.lua resize <h|j|k|l|left|down|up|right> [pixels]   l/right = wider, h/left = narrower, j/down = taller, k/up = shorter
--   window.lua pin                                            toggle "pinned": visible on every workspace and above other windows
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local ipc = require("wfipc")

local DIRECTION = {
  h = { -1, 0 }, left = { -1, 0 }, l = { 1, 0 }, right = { 1, 0 },
  k = { 0, -1 }, up = { 0, -1 }, j = { 0, 1 }, down = { 0, 1 },
}
local MIN_SIZE = 120

local mode = arg[1]
local dir = DIRECTION[arg[2] or ""]
if mode ~= "pin" and ((mode ~= "move" and mode ~= "resize") or not dir) then
  io.stderr:write("usage: window.lua move|resize h|j|k|l [pixels] | pin\n")
  os.exit(2)
end
dir = dir or { 0, 0 }
local step = tonumber(arg[3]) or 40
local dx, dy = dir[1] * step, dir[2] * step

local sock = ipc.connect()
local output = ipc.call(sock, "window-rules/get-focused-output").info
local area = output.workarea or output.geometry

-- Focus can sit on a layer-shell surface (the resize overlay), so pick the newest toplevel on this workspace.
local target
for _, view in ipairs(ipc.call(sock, "window-rules/list-views")) do
  if view["output-id"] == output.id and view.role == "toplevel" and view.mapped and not view.minimized then
    local cx, cy = ipc.center(view)
    if cx >= 0 and cx < area.width and cy >= 0 and cy < area.height then
      if not target or view["last-focus-timestamp"] > target["last-focus-timestamp"] then target = view end
    end
  end
end
if not target or target.fullscreen then return end

if mode == "pin" then
  local on = not target.sticky
  ipc.call(sock, "wm-actions/set-sticky", { view_id = target.id, state = on })
  ipc.call(sock, "wm-actions/set-always-on-top", { view_id = target.id, state = on })
  return
end

local g = target.geometry
local x, y, w, h = g.x, g.y, g.width, g.height

if mode == "move" then
  x = math.max(area.x, math.min(x + dx, area.x + area.width - w))
  y = math.max(area.y, math.min(y + dy, area.y + area.height - h))
else
  local min = target["min-size"] or {}
  w = math.max(min.width or 0, MIN_SIZE, math.min(w + dx, area.x + area.width - x))
  h = math.max(min.height or 0, MIN_SIZE, math.min(h + dy, area.y + area.height - y))
end

local request = { id = target.id, geometry = { x = x, y = y, width = w, height = h } }
if (target["tiled-edges"] or 0) ~= 0 then request["tiled-edges"] = 0 end
ipc.call(sock, "window-rules/configure-view", request)
