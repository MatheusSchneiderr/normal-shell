#!/usr/bin/env lua
-- Dims unfocused windows (not started by default; needs the alpha plugin).
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local ipc = require("wfipc")

local DIM = 0.7

local function apply(sock, focused)
  for _, view in ipairs(ipc.call(sock, "window-rules/list-views")) do
    if view.role == "toplevel" and view.mapped then
      ipc.call(sock, "wf/alpha/set-view-alpha", { ["view-id"] = view.id, alpha = view.id == focused and 1.0 or DIM })
    end
  end
end

local function run()
  local req, watch = ipc.connect(), ipc.connect(-1)
  ipc.call(watch, "window-rules/events/watch", { events = { "view-focused", "view-mapped" } })
  local info = ipc.call(req, "window-rules/get-focused-view").info
  local focused = info and info.id
  apply(req, focused)
  while true do
    local event = ipc.next_message(watch)
    local view = event.view
    if event.event == "view-focused" and view and view.role == "toplevel" then focused = view.id end
    apply(req, focused)
  end
end

while true do
  pcall(run)
  os.execute("sleep 1")
end
