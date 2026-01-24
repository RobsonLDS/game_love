-- ui/panel_frame.lua
local UIElement = require("game_service.ui.ui_element")

local PanelFrame = setmetatable({}, { __index = UIElement })
PanelFrame.__index = PanelFrame

function PanelFrame:new(o)
  o = UIElement.new(self, o)
  o.round = o.round or 0
  o.fillAlpha = o.fillAlpha or 0.0  -- se quiser um leve fundo, ex: 0.06
  return o
end

function PanelFrame:hitTest(mx, my)
  -- painel não precisa capturar clique (quem captura são os botões + blocker)
  return false
end

function PanelFrame:draw()
  if not self.visible then return end

  local dx, dy = self:getDrawOffset()
  local x, y = self.rect.x + dx, self.rect.y + dy

  if self.fillAlpha > 0 then
    love.graphics.setColor(1, 1, 1, self.fillAlpha)
    love.graphics.rectangle("fill", x, y, self.rect.w, self.rect.h, self.round, self.round)
    love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.rectangle("line", x, y, self.rect.w, self.rect.h, self.round, self.round)
end

return PanelFrame
