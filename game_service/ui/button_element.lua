-- ui/button_element.lua
local UIElement = require("game_service.ui.ui_element")

local Button = setmetatable({}, { __index = UIElement })
Button.__index = Button

function Button:new(o)
  o = UIElement.new(self, o)
  o.label = o.label or "Button"
  o.font = o.font or love.graphics.getFont()
  o.onClick = o.onClick

  o.paddingY = o.paddingY or 8
  o.round = o.round or 0

  -- ✅ mesma “força de borda” do card
  o.lineWidthNormal = o.lineWidthNormal or 1
  o.lineWidthHover  = o.lineWidthHover  or 3

  -- ✅ mesmo fundo suave do card
  o.hoverFillAlpha = o.hoverFillAlpha or 0.12

  return o
end

function Button:mousepressed(x, y, button)
  if button ~= 1 then return end
  if not self.enabled or not self.visible then return end
  if self:hitTest(x, y) and self.onClick then
    self.onClick(self)
    return true
  end
end

function Button:draw()
  if not self.visible then return end
  love.graphics.setFont(self.font)

  local dx, dy = self:getDrawOffset()
  local x, y = self.rect.x + dx, self.rect.y + dy

  -- ✅ fundo suave no hover (igual card)
  if self.hover then
    love.graphics.setColor(1, 1, 1, self.hoverFillAlpha)
    love.graphics.rectangle("fill", x, y, self.rect.w, self.rect.h, self.round, self.round)
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- ✅ borda “forte” no hover (igual card)
  love.graphics.setLineWidth(self.hover and self.lineWidthHover or self.lineWidthNormal)
  love.graphics.rectangle("line", x, y, self.rect.w, self.rect.h, self.round, self.round)
  love.graphics.setLineWidth(1)

  love.graphics.printf(self.label, x, y + self.paddingY, self.rect.w, "center")
end

return Button
