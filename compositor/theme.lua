#!/usr/bin/env lua
-- Applies the picked title bar colors and font to Wayfire: theme.lua <active> <inactive> <text> <font>
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local ipc = require("wfipc")

local function opaque(color) return color:sub(1, 7) .. "ff" end

local options = {}
if arg[1] and arg[1] ~= "" then options["decoration/active_color"] = opaque(arg[1]) end
if arg[2] and arg[2] ~= "" then options["decoration/inactive_color"] = opaque(arg[2]) end
if arg[3] and arg[3] ~= "" then options["decoration/font_color"] = opaque(arg[3]) end
if arg[4] and arg[4] ~= "" then options["decoration/font"] = arg[4] end

local sock = ipc.connect()
ipc.call(sock, "wayfire/set-config-options", options)

-- Open windows only repaint their title bar after a size change, so nudge each one by a pixel and back.
for _, view in ipairs(ipc.call(sock, "window-rules/list-views")) do
  if view.role == "toplevel" and view.mapped and not view.fullscreen and not view.minimized and view["tiled-edges"] == 0 then
    local g = view.geometry
    ipc.call(sock, "window-rules/configure-view", { id = view.id, geometry = { x = g.x, y = g.y, width = g.width + 1, height = g.height } })
    ipc.call(sock, "window-rules/configure-view", { id = view.id, geometry = g })
  end
end
