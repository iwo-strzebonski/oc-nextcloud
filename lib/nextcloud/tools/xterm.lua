local term = require("term")
local component = require("component")
local gpu = component.gpu

local XTerm = {}
XTerm.__index = XTerm

XTerm.colors = {
  white = 0xFFFFFF,
  orange = 0xFFA500,
  magenta = 0xFF00FF,
  lightblue = 0xADD8E6,
  yellow = 0xFFFF00,
  lime = 0x00FF00,
  pink = 0xFFC0CB,
  gray = 0x808080,
  silver = 0xC0C0C0,
  cyan = 0x00FFFF,
  purple = 0x800080,
  blue = 0x0000FF,
  brown = 0xA52A2A,
  green = 0x00FF00,
  red = 0xFF0000,
  black = 0x000000,
}

function XTerm:new()
  local instance = setmetatable({}, XTerm)
  return instance
end

function XTerm:prompt(prompt)
  prompt = prompt or "> "
  io.write(prompt)
  return io.read()
end

function XTerm:clear()
  term.clear()
  gpu.setForeground(self.colors.white)
end

function XTerm:print(text, color, isPalette)
  color = color or self.colors.white
  isPalette = isPalette or false

  gpu.setForeground(color, isPalette)
  print(text)
  gpu.setForeground(self.colors.white)
end

return XTerm
