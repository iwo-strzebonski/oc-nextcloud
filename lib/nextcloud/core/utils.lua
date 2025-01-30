local Utils = {}
Utils.__index = Utils

local fs = require("filesystem")

function Utils:new()
  local instance = setmetatable({}, Utils)
  return instance
end

function Utils:loadEnv()
  local io = require("io")
  local env = {}

  if not fs.exists("/home/nextcloud.conf") then
    error("Please provide a /home/nextcloud.conf file")
  end

  for line in io.lines("/home/nextcloud.conf") do
    if line:sub(1, 1) == "#" then
      goto continue
    end

    local key, value = line:match("([^=]+)=(.*)")

    key = Utils:trim(key)
    value = Utils:trim(value)

    if value:sub(1, 1) == '"' or value:sub(1, 1) == "'" then
      value = value:sub(2)
    end
    if value:sub(-1) == '"' or value:sub(-1) == "'" then
      value = value:sub(1, -2)
    end

    env[key] = value

    ::continue::
  end

  return env
end

function Utils:httpRequest(address, headers, data, method)
  method = method or "GET"
  headers = headers or {}
  local inet = require("internet")

  local body = ""
  local response = inet.request(address, data, headers, method)

  for chunk in response do
    body = body .. chunk
  end

  return body
end

function Utils:concatPath(...)
  local paths = { ... }
  local path = table.concat(paths, "/")
  path = path:gsub("//+", "/")

  return path
end

function Utils:trim(s)
  return s:match("^%s*(.-)%s*$")
end

function Utils:getParentDir(path)
  return path:match("(.+)/[^/]+$") or "/"
end

return Utils
