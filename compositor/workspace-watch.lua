#!/usr/bin/env lua
-- Prints one JSON line (workspace grid, current cell, occupied cells) whenever something changes.
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local ipc = require("wfipc")
local cjson = require("cjson")

local function state(sock)
  local output = ipc.call(sock, "window-rules/get-focused-output").info
  local area, ws = output.geometry, output.workspace
  local seen, busy = {}, {}
  for _, view in ipairs(ipc.call(sock, "window-rules/list-views")) do
    if view["output-id"] == output.id and view.role == "toplevel" and view.mapped then
      local box = view.geometry
      local x = ws.x + math.floor((box.x + box.width / 2) / area.width)
      local y = ws.y + math.floor((box.y + box.height / 2) / area.height)
      local key = x .. "," .. y
      if not seen[key] then seen[key] = true; busy[#busy + 1] = { x, y } end
    end
  end
  table.sort(busy, function(a, b) return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2]) end)
  return { w = ws.grid_width, h = ws.grid_height, x = ws.x, y = ws.y, busy = #busy > 0 and busy or cjson.empty_array }
end

local req, watch = ipc.connect(), ipc.connect(-1)
ipc.call(watch, "window-rules/events/watch", {
  events = { "wset-workspace-changed", "view-mapped", "view-unmapped", "view-workspace-changed", "view-geometry-changed" },
})

local last
while true do
  local line = cjson.encode(state(req))
  if line ~= last then
    io.write(line, "\n")
    io.flush()
    last = line
  end
  ipc.next_message(watch)
end
