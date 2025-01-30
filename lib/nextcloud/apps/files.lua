local json = require("lib.nextcloud.tools.json")
local xterm = require("lib.nextcloud.tools.xterm")
local utils = require("lib.nextcloud.core.utils")
local auth = require("lib.nextcloud.core.auth")

Files = {}
Files.__index = Files

function Files:new(env)
  local instance = setmetatable({}, Files)
  local headers = auth:httpBasic(env["NEXTCLOUD_USERNAME"], env["NEXTCLOUD_PASSWORD"])

  instance.authorization = headers["Authorization"]
  instance.username = env["NEXTCLOUD_USERNAME"]
  instance.proxy = env["WEBDAV_PROXY_URL"]
  instance.endpoint = env["NEXTCLOUD_WEBDAV_URL"]
  instance.propfind =
  '<?xml version="1.0" encoding="UTF-8"?><d:propfind xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns"><d:prop><d:displayname /><oc:fileid /><d:getcontenttype/><d:resourcetype/></d:prop></d:propfind>'

  instance.apps = {
    ["dir"] = Files.readDir
  }

  return instance
end

function Files:loop()
  local option = true

  while option and option ~= "exit" do
    xterm:print("NextCloud Files", xterm.colors.cyan)
    xterm:print("---------------", xterm.colors.cyan)
    xterm:print("- dir <path> - List files in directory")
    xterm:print("- back - Go back to main menu")
    xterm:print("- exit (or Ctrl+C) - Exit program")
    input = xterm:prompt("\nYour selection:\n> ")

    if not input then
      break
    end

    option, arg1, arg2 = input:match("(%S+)%s*(%S*)%s*(%S*)")

    if option == "exit" then
      return false
    end

    if option == "back" then
      return true
    end

    local app = self.apps[option]

    if not app then
      xterm:print("Invalid option, please try again.\n", xterm.colors.red)
    elseif app then
      xterm:print("")
      app(self, arg1, arg2)
      xterm:print("")
    end
  end
end

function Files:readDir(path)
  path = path or ""

  local headers = {}
  headers["Authorization"] = self.authorization
  headers["X-Target-Url"] = self.endpoint .. utils:concatPath("/files", self.username, path)

  local response = utils:httpRequest(self.proxy, headers, self.propfind, "POST")

  local data = json.decode(response)

  if type(data) ~= "table" then
    error("Invalid JSON response")
  end

  local isRoot = not path or path == "" or path == "/" or path == "." or path == ".."

  if isRoot then
    xterm:print("/ (root)", xterm.colors.orange)
  else
    local parentDir = utils:getParentDir(path)

    xterm:print(". (" .. path .. ")", xterm.colors.orange)
    xterm:print(".. (" .. parentDir .. ")", xterm.colors.orange)
  end

  for _, v in pairs(data) do
    if v["displayname"] == "." or v["displayname"] == ".." then
      goto continue
    end

    local color = xterm.colors.white

    if v["isdirectory"] then
      color = xterm.colors.blue
    elseif
    --   v["contenttype"].sub(1, 5) == "image"
    --   or v["contenttype"].sub(1, 5) == "video"
        v["contenttype"].sub(1, 5) == "application/vnd.openxmlformats-officedocument.graphics"
    then
      --   color = xterm.colors.magenta
      color = xterm.colors.white
      -- elseif
      --   v["contenttype"].sub(1, 5) == "audio"
      -- then
      --   color = xterm.colors.pink
    elseif
        v["contenttype"] == "application/pdf"
        or v["contenttype"]:find("text/markdown")
        or v["contenttype"]:find("^application/vnd.oasis.opendocument")
        or v["contenttype"]:find("^application/vnd.openxmlformats-officedocument")
    then
      color = xterm.colors.lime
    end

    xterm:print(v["displayname"], color)

    ::continue::
  end

  return data
end

return Files
