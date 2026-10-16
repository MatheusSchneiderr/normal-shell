#!/usr/bin/env lua
-- Focus the nearest window in a direction; with none left, switch to the neighbouring workspace.
--   edge-focus.lua <left|right|up|down>   move focus
--   edge-focus.lua send <direction>       carry the focused window along
--   edge-focus.lua goto X Y               jump to a workspace
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local ipc = require("wfipc")

local STEP = { left = { -1, 0 }, right = { 1, 0 }, up = { 0, -1 }, down = { 0, 1 } }

local sock = ipc.connect()
local mode = arg[1]
local output = ipc.call(sock, "window-rules/get-focused-output").info

if mode == "goto" then
  ipc.call(sock, "vswitch/set-workspace", { x = tonumber(arg[2]), y = tonumber(arg[3]), ["output-id"] = output.id })
  return
end

local carry = mode == "send"
local step = STEP[carry and arg[2] or mode]
if not step then io.stderr:write("usage: edge-focus.lua left|right|up|down | send <dir> | goto X Y\n") os.exit(2) end
local dx, dy = step[1], step[2]
local area, ws = output.geometry, output.workspace

local focused = ipc.call(sock, "window-rules/get-focused-view").info
local ox, oy
if focused and focused["output-id"] == output.id then
  ox, oy = ipc.center(focused)
else
  focused = nil
  ox, oy = area.width / 2, area.height / 2
end

local function switch(view_id)
  local x, y = ws.x + dx, ws.y + dy
  if x < 0 or y < 0 or x >= ws.grid_width or y >= ws.grid_height then return end
  ipc.call(sock, "vswitch/set-workspace", { x = x, y = y, ["output-id"] = output.id, ["view-id"] = view_id })
end

if carry then
  if focused then
    switch(focused.id)
    ipc.call(sock, "window-rules/focus-view", { id = focused.id })
  end
  return
end

local best, best_score
for _, view in ipairs(ipc.call(sock, "window-rules/list-views")) do
  local candidate = view["output-id"] == output.id and view.role == "toplevel" and view.mapped
    and not view.minimized and view.focusable and not (focused and view.id == focused.id)
  if candidate then
    local cx, cy = ipc.center(view)
    if cx >= 0 and cx < area.width and cy >= 0 and cy < area.height then
      local along = (cx - ox) * dx + (cy - oy) * dy
      local across = math.abs((cx - ox) * dy + (cy - oy) * dx)
      if along > 0 then
        local score = along + 2 * across
        if not best_score or score < best_score then best, best_score = view, score end
      end
    end
  end
end

if best then
  ipc.call(sock, "window-rules/focus-view", { id = best.id })
else
  switch(nil)
end
