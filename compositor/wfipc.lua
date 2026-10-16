-- Wayfire IPC: a unix socket speaking length-prefixed JSON (4-byte little-endian size, then the body).
local unix = require("socket.unix")
local cjson = require("cjson")

local M = {}

local function socket_path()
  local explicit = os.getenv("WAYFIRE_SOCKET")
  if explicit and explicit ~= "" then return explicit end
  return string.format("%s/wayfire-%s-.socket", os.getenv("XDG_RUNTIME_DIR"), os.getenv("WAYLAND_DISPLAY") or "wayland-1")
end

function M.connect(timeout)
  local sock = assert(unix())
  sock:settimeout(timeout or 3)
  local ok, err = sock:connect(socket_path())
  if not ok then
    io.stderr:write("wayfire socket not found: ", tostring(err), "\n")
    os.exit(1)
  end
  return sock
end

-- LuaSocket's receive returns extra values, so keep only the first.
function M.read(sock, size)
  local data, err = sock:receive(size)
  if not data then error(err or "closed") end
  return data
end

function M.call(sock, method, data)
  local body = '{"method":' .. cjson.encode(method) .. ',"data":' .. (data and cjson.encode(data) or "{}") .. "}"
  sock:send(string.pack("<I4", #body) .. body)
  return M.next_message(sock)
end

-- JSON null becomes nil, so `reply.info` is simply nil when Wayfire has no focused view.
local function strip_nulls(value)
  if type(value) ~= "table" then return value end
  for key, item in pairs(value) do
    if item == cjson.null then value[key] = nil else strip_nulls(item) end
  end
  return value
end

function M.next_message(sock)
  local size = string.unpack("<I4", M.read(sock, 4))
  return strip_nulls(cjson.decode(M.read(sock, size)))
end

function M.center(view)
  local box = view.geometry
  return box.x + box.width / 2, box.y + box.height / 2
end

return M
