-- ui/ui_element.lua
local utils = require("game_service.utils")
local shake = require("game_service.ui.shake")

local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(o)
  o = o or {}
  setmetatable(o, self)

  o.id = o.id or ("ui_" .. tostring(o):gsub("table: ", ""))
  o.rect = o.rect or { x = 0, y = 0, w = 0, h = 0 }

  o.visible = (o.visible ~= false)
  o.enabled = (o.enabled ~= false)

  -- hover state (opcional, mas útil)
  o.hover = false

  -- shake config (pulso)
  o.shakeDuration = o.shakeDuration or 0.10
  o.shakeStrength = o.shakeStrength or 4

  return o
end

function UIElement:setRect(x, y, w, h)
  self.rect.x, self.rect.y, self.rect.w, self.rect.h = x, y, w, h
end

function UIElement:hitTest(mx, my)
  if not self.visible or not self.enabled then return false end
  return utils.pointInRect(mx, my, self.rect)
end

function UIElement:update(dt, mx, my)
  if not self.visible then return end

  local isHover = self:hitTest(mx, my)
  self.hover = isHover

  -- pulso na entrada
  shake.hoverPulse(self.id, isHover, self.shakeDuration, self.shakeStrength)
end

function UIElement:getDrawOffset()
  local dx, dy = shake.getShakeOffset(self.id)
  return dx, dy
end

function UIElement:draw()
  if self.hover then
    love.graphics.setColor(1,0,0,0.3)
    love.graphics.rectangle("line", self.rect.x, self.rect.y, self.rect.w, self.rect.h)
    love.graphics.setColor(1,1,1,1)
  end
  -- base não desenha nada (classe abstrata)
end

function UIElement:mousepressed(x, y, button)
  -- base não faz nada
end

return UIElement
