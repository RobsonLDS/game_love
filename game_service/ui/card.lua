-- ui/card.lua
local UIElement = require("game_service.ui.ui_element")
local utils = require("game_service.utils")

local Card = setmetatable({}, { __index = UIElement })
Card.__index = Card

function Card:new(o)
  o = UIElement.new(self, o)
  o.mode = o.mode
  o.titleFont = o.titleFont or love.graphics.getFont()
  o.bodyFont  = o.bodyFont  or love.graphics.getFont()
  o.onClick = o.onClick -- function(self)

  o.thumb = o.thumb -- image (opcional)
  o.i18n = o.i18n   -- para texto (opcional)

  return o
end

function Card:mousepressed(x, y, button)
  if button ~= 1 then return end
  if not self.enabled or not self.visible then return end
  if self:hitTest(x, y) and self.onClick then
    self.onClick(self)
  end
end

function Card:draw()
  if not self.visible then return end

  local dx, dy = self:getDrawOffset()
  local rx, ry = self.rect.x + dx, self.rect.y + dy

  -- fundo hover
  if self.hover then
    love.graphics.setColor(1, 1, 1, 0.12)
    love.graphics.rectangle("fill", rx, ry, self.rect.w, self.rect.h)
    love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.setLineWidth(self.hover and 3 or 1)
  love.graphics.rectangle("line", rx, ry, self.rect.w, self.rect.h)
  love.graphics.setLineWidth(1)

  -- thumb
  local thumbX, thumbY = rx + 12, ry + 12
  local thumbW, thumbH = 116, 116
  love.graphics.rectangle("line", thumbX, thumbY, thumbW, thumbH)

  if self.mode and self.mode.image then
    local img = self.mode.image
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = math.min(thumbW / iw, thumbH / ih)
    local drawW, drawH = iw * scale, ih * scale
    local ddx = thumbX + (thumbW - drawW) / 2
    local ddy = thumbY + (thumbH - drawH) / 2
    love.graphics.draw(img, ddx, ddy, 0, scale, scale)
  end

  -- texto
  local textX = thumbX + thumbW + 14
  local textW = self.rect.w - (textX - rx) - 12

  if self.mode then
    love.graphics.setFont(self.titleFont)
    love.graphics.print(self.mode.title or "<mode>", textX, ry + 12)

    love.graphics.setFont(self.bodyFont)
    local desc = self.mode.description or ""
    local lines = utils.wrapText(self.bodyFont, desc, textW)
    for li = 1, math.min(#lines, 5) do
      love.graphics.print(lines[li], textX, ry + 44 + (li - 1) * 18)
    end
  end
end

return Card
