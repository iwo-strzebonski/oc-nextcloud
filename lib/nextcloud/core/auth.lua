local base64 = require("lib.nextcloud.tools.base64")
local xterm = require("lib.nextcloud.tools.xterm")

local Auth = {}
Auth.__index = Auth

function Auth:new(env)
  local instance = setmetatable({}, Auth)

  instance.env = env

  return instance
end

function Auth:getCredentials()
  local username = self.env["NEXTCLOUD_USERNAME"]
  local password = self.env["NEXTCLOUD_PASSWORD"]

  return username, password
end

function Auth:readCredentialsFromInput()
  local username = xterm:prompt("Please provide your Nextcloud username: ")
  local password = xterm:prompt("Please provide your Nextcloud password: ")

  return username, password
end

function Auth:storeCredentials(username, password)
  print(self.env)

  username = username or self.env["NEXTCLOUD_USERNAME"]
  password = password or self.env["NEXTCLOUD_PASSWORD"]

  local io = require("io")

  local file = io.open("/home/nextcloud.conf", "a")

  if file == nil then
    file = io.open("/home/nextcloud.conf", "w")
  end

  file:write("\nNEXTCLOUD_USERNAME=" .. username .. "\n")
  file:write("NEXTCLOUD_PASSWORD=" .. password .. "\n")
  file:close()
end

function Auth:httpBasic(username, password)
  username = username or self.env["NEXTCLOUD_USERNAME"]
  password = password or self.env["NEXTCLOUD_PASSWORD"]

  print("Username: " .. username)
  print("Password: " .. password)

  headers = {
    ["Authorization"] = "Basic " .. base64:encode(username .. ":" .. password)
  }

  return headers
end

return Auth
