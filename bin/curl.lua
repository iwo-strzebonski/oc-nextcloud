local component = require("component")
local internet = require("internet")
local shell = require("shell")

local base64 = require("lib.nextcloud.tools.base64")

local args, options = shell.parse(...)

if #args < 1 then
  print("Usage: curl <url> [options]")
  print("Options:")
  print("  --X, --request='<method>'  Specify request method (GET, POST, etc.)")
  print("  --d='<data>'    Data to send in a POST request")
  print("  --H='<header>'  Pass custom header(s) to server")
  print("  --T='<header>'  Pass X-Target-Url header to server")
  print("  --u='<user:password>'  Specify user and password for server authentication")
  os.exit(1)
end

local url = args[1]
local method = options.X or options.request or "GET"
local postData = options.d or nil
local headers = {}

if options.H then
  for _, header in ipairs(options.H) do
    local name, value = header:match("([^:]+):%s*(.+)")
    if name and value then
      headers[name] = value
    else
      print("Invalid header format: " .. header)
      os.exit(1)
    end
  end
end

if options.u then
  local auth = base64:encode(options.u)

  headers["Authorization"] = "Basic " .. auth
end

if options.T then
  headers["X-Target-Url"] = options.T
end

if method == "POST" and not postData then
  print(method .. " method requires data (--d option).")
  os.exit(1)
end

local result = ""
local request

okay, request = pcall(internet.request, url, postData, headers, method)

for chunk in request do
  result = result .. chunk
end

print(result)
