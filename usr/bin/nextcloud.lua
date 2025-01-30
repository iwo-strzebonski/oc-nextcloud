local PROGRAM_NAME = "NextCloud OC Integration"
local VERSION = "1.0.0"
local AUTHOR = "Octoturge"

local utils = require("lib.nextcloud.core.utils")
local auth = require("lib.nextcloud.core.auth")
local files = require("lib.nextcloud.apps.files")
local xterm = require("lib.nextcloud.tools.xterm")

local apps = {}
apps["files"] = files:new(utils:loadEnv())

xterm:clear()

local env = utils:loadEnv()

if env["NEXTCLOUD_USERNAME"] == nil or env["NEXTCLOUD_PASSWORD"] == nil then
  local username, password = auth:readCredentialsFromInput()

  if username == nil or password == nil then
    xterm:print("Please provide NEXTCLOUD_USERNAME and NEXTCLOUD_PASSWORD in the /home/nextcloud.conf file", xterm
      .colors
      .red)
    os.exit(1)
  end

  env["NEXTCLOUD_USERNAME"] = username
  env["NEXTCLOUD_PASSWORD"] = password

  auth:storeCredentials(username, password)
end

if env["NEXTCLOUD_OCS_URL"] == nil then
  xterm:print("Please provide NEXTCLOUD_OCS_URL in the /home/nextcloud.conf file", xterm.colors.red)
  os.exit(1)
end

if env["NEXTCLOUD_WEBDAV_URL"] == nil then
  xterm:print("Please provide NEXTCLOUD_WEBDAV_URL in the /home/nextcloud.conf file", xterm.colors.red)
  os.exit(1)
end

if env["WEBDAV_PROXY_URL"] == nil then
  xterm:print("Please provide WEBDAV_PROXY_URL in the /home/nextcloud.conf file", xterm.colors.red)
  xterm:print("Proxy is used to convert GET or POST requests to PROPFIND requests", xterm.colors.yellow)
  xterm:print("Because MightyPirates suck and their `component.internet.request`", xterm.colors.yellow)
  xterm:print("does not accept the `method` parameter", xterm.colors.yellow)
  xterm:print("DESPITE `internet.request` HAVING THAT SHIT WTF", xterm.colors.yellow)
  os.exit(1)
end

xterm:print(PROGRAM_NAME .. "v " .. VERSION, xterm.colors.gray)
xterm:print("by " .. AUTHOR .. "\n", xterm.colors.gray)

local motd = "Welcome, " .. env["NEXTCLOUD_USERNAME"] .. "!"

xterm:print(motd, xterm.colors.lightblue)
xterm:print(string.rep("-", #motd), xterm.colors.lightblue)

local option = true
local doLoop = true

while option and doLoop and option ~= "exit" do
  xterm:print("\nMain menu", xterm.colors.cyan)
  xterm:print("---------", xterm.colors.cyan)

  for o in pairs(apps) do
    xterm:print(" - " .. o)
  end

  xterm:print(" - exit")

  option = xterm:prompt("\nYour selection:\n> ")
  xterm:print("")

  local app = apps[option]

  if option and option ~= "exit" and not app then
    xterm:print("Invalid option, please try again.", xterm.colors.red)
  elseif app then
    doLoop = app:loop()
  end
end

xterm:print("\nThank you for using our program!", xterm.colors.lightblue)
xterm:print("--------------------------------\n", xterm.colors.lightblue)
