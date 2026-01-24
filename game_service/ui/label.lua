-- ui/label.lua
local UIElement = require("game_service.ui.ui_element")

local Label = setmetatable({}, { __index = UIElement })
Label.__index = Label

function Label:new(o)
  o = UIElement.new(self, o)
  o.text = o.text or ""
  o.font = o.font or love.graphics.getFont()
  o.color = o.color or { 1, 1, 1, 1 }
  return o
end

function Label:setText(text)
  self.text = text or ""
end

function Label:measure()
  love.graphics.setFont(self.font)
  local w = self.font:getWidth(self.text)
  local h = self.font:getHeight()
  return w, h
end

function Label:autoRect(x, y)
  local w, h = self:measure()
  self:setRect(x, y, w, h)
end

function Label:draw()
  if not self.visible then return end
  love.graphics.setFont(self.font)

  local dx, dy = self:getDrawOffset()

  love.graphics.setColor(self.color)
  love.graphics.print(self.text, self.rect.x + dx, self.rect.y + dy)
  love.graphics.setColor(1, 1, 1, 1)
end

return Label
