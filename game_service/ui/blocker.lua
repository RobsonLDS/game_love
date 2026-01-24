-- ui/blocker.lua
local UIElement = require("game_service.ui.ui_element")

local Blocker = setmetatable({}, { __index = UIElement })
Blocker.__index = Blocker

function Blocker:new(o)
  o = UIElement.new(self, o)
  o.alpha = o.alpha or 0.22
  o.onClickOutside = o.onClickOutside -- function(self, x, y)
  o.panelRect = o.panelRect -- rect do painel; se clicar fora -> fecha
  return o
end

function Blocker:hitTest(mx, my)
  if not self.visible or not self.enabled then return false end
  -- Blocker sempre “pega” clique em qualquer lugar da tela
  return true
end

function Blocker:mousepressed(x, y, button)
  if button ~= 1 then return false end
  if not self.visible or not self.enabled then return false end

  -- se tiver panelRect, só fecha se clicar fora do painel
  if self.panelRect then
    local r = self.panelRect
    local inside = (x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h)
    if inside then
      return true -- consome, mas não fecha
    end
  end

  if self.onClickOutside then
    self.onClickOutside(self, x, y)
  end
  return true
end

function Blocker:draw()
  if not self.visible then return end
  love.graphics.setColor(1, 1, 1, self.alpha)
  love.graphics.rectangle("fill", self.rect.x, self.rect.y, self.rect.w, self.rect.h)
  love.graphics.setColor(1, 1, 1, 1)
end

return Blocker
