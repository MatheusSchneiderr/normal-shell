#!/usr/bin/env lua
-- Default applications.
--   mime-apps.lua state [MIME...]   installed apps and current defaults (resolved for the given MIMEs) as JSON
--   mime-apps.lua set ID MIME...    make ID the default for each MIME
local cjson = require("cjson")

local home = os.getenv("HOME")
local function env(name, default) local v = os.getenv(name); return (v and v ~= "") and v or default end

local function quote(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

local function lines(command)
  local out = {}
  local pipe = io.popen(command)
  if pipe then
    for line in pipe:lines() do out[#out + 1] = line end
    pipe:close()
  end
  return out
end

local function is_dir(path) return os.execute("test -d " .. quote(path)) == true end

local function data_dirs()
  local dirs = { env("XDG_DATA_HOME", home .. "/.local/share") }
  for dir in env("XDG_DATA_DIRS", "/usr/local/share:/usr/share"):gmatch("[^:]+") do dirs[#dirs + 1] = dir end
  dirs[#dirs + 1] = home .. "/.nix-profile/share"
  dirs[#dirs + 1] = "/etc/profiles/per-user/" .. env("USER", "") .. "/share"
  dirs[#dirs + 1] = "/run/current-system/sw/share"
  local seen, out = {}, {}
  for _, dir in ipairs(dirs) do
    if not seen[dir] and is_dir(dir .. "/applications") then seen[dir] = true; out[#out + 1] = dir end
  end
  return out
end

local function read_entry(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local entry, inside = {}, false
  for line in file:lines() do
    local section = line:match("^%[(.-)%]%s*$")
    if section then
      inside = section == "Desktop Entry"
    elseif inside then
      local key, value = line:match("^([%w%-]+)=(.*)$")
      if key then entry[key] = value end
    end
  end
  file:close()
  return entry
end

local function apps()
  local found = {}
  for _, base in ipairs(data_dirs()) do
    local root = base .. "/applications"
    for _, path in ipairs(lines("find -L " .. quote(root) .. " -name '*.desktop' -type f 2>/dev/null")) do
      local id = path:sub(#root + 2):gsub("/", "-")
      if not found[id] then
        local entry = read_entry(path)
        if entry and entry.Hidden ~= "true" and (entry.Type or "Application") == "Application" then
          local mimes = {}
          for mime in (entry.MimeType or ""):gmatch("[^;]+") do mimes[#mimes + 1] = mime end
          if #mimes > 0 then found[id] = { id = id, name = entry.Name or id, mimes = mimes } end
        end
      end
    end
  end
  local list = {}
  for _, app in pairs(found) do list[#list + 1] = app end
  table.sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
  return list
end

local function defaults()
  local config = env("XDG_CONFIG_HOME", home .. "/.config")
  local paths = { config .. "/mimeapps.list", env("XDG_DATA_HOME", home .. "/.local/share") .. "/applications/mimeapps.list" }
  for dir in env("XDG_CONFIG_DIRS", "/etc/xdg"):gmatch("[^:]+") do paths[#paths + 1] = dir .. "/mimeapps.list" end
  local result = {}
  for _, path in ipairs(paths) do
    local file = io.open(path, "r")
    if file then
      local inside = false
      for line in file:lines() do
        local section = line:match("^%[(.-)%]%s*$")
        if section then
          inside = section == "Default Applications"
        elseif inside then
          local mime, value = line:match("^([^=]+)=(.*)$")
          local first = value and value:match("[^;]+")
          if mime and first and not result[mime] then result[mime] = first end
        end
      end
      file:close()
    end
  end
  return result
end

local function effective(mimes)
  local result = {}
  for _, mime in ipairs(mimes) do
    local out = lines("xdg-mime query default " .. quote(mime))[1]
    if out and out ~= "" then result[mime] = out end
  end
  return result
end

local command = arg[1] or "state"
if command == "state" then
  local current = defaults()
  for mime, id in pairs(effective({ table.unpack(arg, 2) })) do current[mime] = id end
  local list = apps()
  io.write(cjson.encode({ apps = #list > 0 and list or cjson.empty_array, defaults = current }), "\n")
elseif command == "set" and #arg > 2 then
  local parts = { "xdg-mime default", quote(arg[2]) }
  for i = 3, #arg do parts[#parts + 1] = quote(arg[i]) end
  os.execute(table.concat(parts, " "))
else
  io.stderr:write("usage: mime-apps.lua state [MIME...] | set ID MIME...\n")
  os.exit(2)
end
