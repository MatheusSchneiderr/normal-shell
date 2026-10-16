#!/usr/bin/env lua
-- Applies the picked keyboard layout to Wayfire: input.lua <layout> <variant>
package.path = (arg[0]:match("^(.*)/[^/]*$") or ".") .. "/?.lua;" .. package.path
local ipc = require("wfipc")

if not arg[1] or arg[1] == "" then os.exit(0) end

local sock = ipc.connect()
ipc.call(sock, "wayfire/set-config-options", {
  ["input/xkb_layout"] = arg[1],
  ["input/xkb_variant"] = arg[2] or "",
})
